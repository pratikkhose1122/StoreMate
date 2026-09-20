import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://foo.supabase.co',
    anonKey: 'bar',
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );
}
