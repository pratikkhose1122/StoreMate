import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:printing/printing.dart';
import 'package:decimal/decimal.dart';
import '../../../../core/utils/currency_formatter.dart';

class _InvoiceTheme {
  static const primaryDark = PdfColor.fromInt(0xFF1B2A4A);
  static const primaryLight = PdfColor.fromInt(0xFFF0F4F8);
  static const accentColor = PdfColor.fromInt(0xFF0D7377);
  static const borderColor = PdfColor.fromInt(0xFFD0D5DD);
  static const mutedText = PdfColor.fromInt(0xFF667085);
  static const bodyText = PdfColor.fromInt(0xFF1D2939);
  static const white = PdfColor.fromInt(0xFFFFFFFF);
  static const dangerColor = PdfColor.fromInt(0xFFB42318);
  static const successColor = PdfColor.fromInt(0xFF027A48);
}

abstract class InvoiceTemplateService {
  Future<Uint8List> generateInvoice(ShopModel shop, SaleModel sale);
}

class ClassicInvoiceTemplate implements InvoiceTemplateService {
  @override
  Future<Uint8List> generateInvoice(ShopModel shop, SaleModel sale) async {
    final pdf = pw.Document();
    
    // Load Roboto TTF fonts via Google Fonts for Rupee (₹) symbol support
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final logoImage = await _loadShopLogo(shop.logoUrl);

    _buildProfessionalInvoice(pdf, shop, sale, fontRegular, fontBold, logoImage);

    return pdf.save();
  }

  Future<pw.ImageProvider?> _loadShopLogo(String? logoUrl) async {
    if (logoUrl == null || logoUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(logoUrl.trim());

    if (uri == null) {
      return null;
    }

    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    try {
      return await networkImage(logoUrl);
    } catch (_) {
      return null;
    }
  }

  void _buildProfessionalInvoice(
    pw.Document pdf, 
    ShopModel shop, 
    SaleModel sale, 
    pw.Font fontRegular, 
    pw.Font fontBold,
    pw.ImageProvider? logoImage,
  ) {
    // Prioritize historical SaleModel snapshots over current Shop Info for accuracy
    final shopName = sale.shopNameSnapshot ?? shop.name;
    final shopAddress = sale.shopAddressSnapshot ?? shop.address;
    final shopPhone = sale.shopPhoneSnapshot ?? shop.mobileNumber;
    final shopGstin = shop.gstNumber; // GSTIN is not snapshotted, fallback to current shop
    final upiId = shop.upiId;

    final dateStr = sale.createdAt != null ? DateFormat('dd MMM yyyy').format(sale.createdAt!) : '';
    final timeStr = sale.createdAt != null ? DateFormat('hh:mm a').format(sale.createdAt!) : '';
    final dateTimeDisplay = dateStr.isNotEmpty && timeStr.isNotEmpty ? '$dateStr, $timeStr' : (dateStr.isNotEmpty ? dateStr : '');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: _InvoiceTheme.primaryDark,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (logoImage != null)
                            pw.Container(
                              width: 60,
                              height: 60,
                              margin: const pw.EdgeInsets.only(right: 16),
                              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                            ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(shopName, style: pw.TextStyle(font: fontBold, fontSize: 16, color: _InvoiceTheme.white)),
                                pw.SizedBox(height: 6),
                                if (shopAddress != null && shopAddress.isNotEmpty)
                                  pw.Text(shopAddress, style: pw.TextStyle(font: fontRegular, fontSize: 9, color: _InvoiceTheme.white)),
                                if (shopPhone != null && shopPhone.isNotEmpty)
                                  pw.Text('Phone: $shopPhone', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: _InvoiceTheme.white)),
                                if (shopGstin != null && shopGstin.isNotEmpty)
                                  pw.Text('GSTIN: $shopGstin', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _InvoiceTheme.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('TAX INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 18, letterSpacing: 1.2, color: _InvoiceTheme.white)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
            ],
          );
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(height: 20),
              pw.Divider(color: _InvoiceTheme.borderColor),
              pw.SizedBox(height: 12),
              pw.Text('Thank you for shopping with us', style: pw.TextStyle(font: fontBold, fontSize: 11, color: _InvoiceTheme.bodyText)),
              if (upiId != null && upiId.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text('Pay via UPI: $upiId', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: _InvoiceTheme.mutedText)),
              ],
              pw.SizedBox(height: 12),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: _InvoiceTheme.mutedText)),
            ],
          );
        },
        build: (context) {
          return [
            // Meta Info and Customer Info Box
            pw.Container(
              decoration: pw.BoxDecoration(
                color: _InvoiceTheme.primaryLight,
                border: pw.Border.all(color: _InvoiceTheme.borderColor, width: 1),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Invoice Number and Date
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: _InvoiceTheme.borderColor, width: 1))),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('INVOICE NO.', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _InvoiceTheme.mutedText)),
                              pw.SizedBox(height: 4),
                              pw.Text(sale.invoiceNumber, style: pw.TextStyle(font: fontBold, fontSize: 11, color: _InvoiceTheme.bodyText)),
                            ],
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('DATE & TIME', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _InvoiceTheme.mutedText)),
                              pw.SizedBox(height: 4),
                              pw.Text(dateTimeDisplay, style: pw.TextStyle(font: fontBold, fontSize: 11, color: _InvoiceTheme.bodyText)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(color: _InvoiceTheme.borderColor, height: 1, thickness: 1),
                  // Bottom Row: Customer and Payment
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: _InvoiceTheme.borderColor, width: 1))),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('CUSTOMER', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _InvoiceTheme.mutedText)),
                              pw.SizedBox(height: 4),
                              pw.Text(sale.customer?.name ?? 'Walk-in Customer', style: pw.TextStyle(font: fontBold, fontSize: 11, color: _InvoiceTheme.bodyText)),
                              if (sale.customer?.mobileNumber != null && sale.customer!.mobileNumber!.isNotEmpty)
                                pw.Text('Phone: ${sale.customer!.mobileNumber}', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: _InvoiceTheme.bodyText)),
                              if (sale.customer?.email != null && sale.customer!.email!.isNotEmpty)
                                pw.Text('Email: ${sale.customer!.email}', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: _InvoiceTheme.bodyText)),
                              if (sale.customer?.address != null && sale.customer!.address!.isNotEmpty)
                                pw.Text('Address: ${sale.customer!.address}', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: _InvoiceTheme.bodyText)),
                            ],
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('PAYMENT', style: pw.TextStyle(font: fontBold, fontSize: 9, color: _InvoiceTheme.mutedText)),
                              pw.SizedBox(height: 4),
                              pw.Text(sale.payments.isNotEmpty ? sale.payments.first.paymentMethod.toUpperCase() : 'N/A', style: pw.TextStyle(font: fontBold, fontSize: 11, color: _InvoiceTheme.bodyText)),
                              pw.SizedBox(height: 4),
                              if (sale.amountDue > Decimal.zero)
                                pw.Text('Status: DUE', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _InvoiceTheme.dangerColor))
                              else
                                pw.Text('Status: PAID', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _InvoiceTheme.successColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Product Table
            pw.Table(
              border: pw.TableBorder.all(color: _InvoiceTheme.borderColor, width: 1),
              columnWidths: const {
                0: pw.FixedColumnWidth(32), // #
                1: pw.FlexColumnWidth(4),   // Product
                2: pw.FixedColumnWidth(40), // Qty
                3: pw.FlexColumnWidth(1.5), // Unit Price
                4: pw.FlexColumnWidth(1),   // Tax
                5: pw.FlexColumnWidth(1.5), // Amount
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _InvoiceTheme.primaryDark),
                  children: [
                    _buildHeaderCell('#', pw.Alignment.center, fontBold),
                    _buildHeaderCell('PRODUCT', pw.Alignment.centerLeft, fontBold),
                    _buildHeaderCell('QTY', pw.Alignment.center, fontBold),
                    _buildHeaderCell('UNIT PRICE', pw.Alignment.centerRight, fontBold),
                    _buildHeaderCell('TAX', pw.Alignment.centerRight, fontBold),
                    _buildHeaderCell('AMOUNT', pw.Alignment.centerRight, fontBold),
                  ],
                ),
                // Table Rows
                ...List<pw.TableRow>.generate(
                  sale.items.length,
                  (index) {
                    final item = sale.items[index];
                    final isEven = index % 2 == 0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: isEven ? _InvoiceTheme.primaryLight : _InvoiceTheme.white),
                      children: [
                        _buildBodyCell('${index + 1}', pw.Alignment.center, fontRegular),
                        _buildBodyCell(item.productName, pw.Alignment.centerLeft, fontRegular),
                        _buildBodyCell(CurrencyFormatter.format(item.quantity), pw.Alignment.center, fontRegular),
                        _buildBodyCell('₹${CurrencyFormatter.format(item.unitPrice)}', pw.Alignment.centerRight, fontRegular),
                        _buildBodyCell(item.taxPercentage > Decimal.zero ? '${CurrencyFormatter.format(item.taxPercentage)}%' : '—', pw.Alignment.centerRight, fontRegular),
                        _buildBodyCell('₹${CurrencyFormatter.format(item.subtotal)}', pw.Alignment.centerRight, fontRegular),
                      ],
                    );
                  },
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            
            // Financial Summary & Totals
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _InvoiceTheme.borderColor, width: 1),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal', sale.netAmount, fontRegular, false, showTopBorder: false),
                        if (sale.discountAmount > Decimal.zero)
                          _buildTotalRow('Discount', -sale.discountAmount, fontRegular, false, valueColor: _InvoiceTheme.successColor),
                        if (sale.taxAmount > Decimal.zero)
                          _buildTotalRow('Tax', sale.taxAmount, fontRegular, false),
                        _buildTotalRow('GRAND TOTAL', sale.totalAmount, fontBold, true),
                        if (sale.amountDue > Decimal.zero) ...[
                          _buildTotalRow('Paid Amount', sale.amountPaid, fontRegular, false),
                          _buildTotalRow('Balance Due', sale.amountDue, fontBold, false, valueColor: _InvoiceTheme.dangerColor),
                        ],
                        if ((sale.refundAmount ?? Decimal.zero) > Decimal.zero)
                          _buildTotalRow('Refunded', -(sale.refundAmount ?? Decimal.zero), fontRegular, false, valueColor: _InvoiceTheme.dangerColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Alignment alignment, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9, color: _InvoiceTheme.white),
      ),
    );
  }

  pw.Widget _buildBodyCell(String text, pw.Alignment alignment, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, color: _InvoiceTheme.bodyText),
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, Decimal value, pw.Font font, bool isGrandTotal, {PdfColor? valueColor, bool showTopBorder = true}) {
    final bgColor = isGrandTotal ? _InvoiceTheme.accentColor : _InvoiceTheme.white;
    final textColor = isGrandTotal ? _InvoiceTheme.white : (valueColor ?? _InvoiceTheme.bodyText);
    
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: isGrandTotal ? 12 : 8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: showTopBorder ? const pw.Border(
          top: pw.BorderSide(color: _InvoiceTheme.borderColor, width: 1)
        ) : null,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: isGrandTotal ? 12 : 10, color: textColor)),
          pw.Text(
            value < Decimal.zero ? '-₹${CurrencyFormatter.format(value.abs())}' : '₹${CurrencyFormatter.format(value)}', 
            style: pw.TextStyle(font: font, fontSize: isGrandTotal ? 13 : 10, color: textColor)
          ),
        ],
      ),
    );
  }
}
