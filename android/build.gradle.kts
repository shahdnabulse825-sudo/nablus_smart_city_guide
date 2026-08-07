allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// بعض الحزم القديمة (مثل record) ما بتحدد namespace بملف الـ Gradle تبعها،
// وهاد مطلوب إلزاميًا بإصدارات Android Gradle Plugin الحديثة.
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension) {
            if (androidExtension.namespace == null) {
                androidExtension.namespace = if (project.name == "record") {
                    "com.llfbandit.record"
                } else {
                    "com.nabligo.${project.name.replace("-", "_")}"
                }
            }
        }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
