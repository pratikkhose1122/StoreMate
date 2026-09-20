allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Fix for older plugins that don't declare a namespace (required by AGP 8+)
// and bump compileSdk to 34 to avoid 'lStar' AAPT errors on old plugins
subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace.isNullOrEmpty()) {
            android.namespace = project.group.toString().ifEmpty { "com.example.${project.name.replace("-", "_")}" }
        }
        android.compileSdk = 34
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name == "camera_android_camerax") {
        project.configurations.all {
            if (name.contains("compile") || name.contains("api") || name.contains("implementation")) {
                dependencies.add(project.dependencies.create("androidx.concurrent:concurrent-futures:1.1.0"))
                dependencies.add(project.dependencies.create("com.google.guava:guava:31.1-android"))
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
