// Root-level build.gradle.kts
plugins {
    // ❌ Don't apply application plugin at root
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false // ✅ Correct version
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Optional: Relocate the build directory (if you're managing nested builds)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
