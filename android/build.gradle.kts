// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google() // Google Maven repository for Android and Firebase plugins
        mavenCentral() // Central Maven repository
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // Android Gradle plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0") // Kotlin plugin
        classpath("com.google.gms:google-services:4.4.3") // Google Services plugin with explicit version
    }
}

allprojects {
    repositories {
        google() // Ensure all projects use Google Maven
        mavenCentral() // Ensure all projects use Maven Central
    }
}

rootProject.buildDir = rootProject.layout.buildDirectory.dir("../../build").get().asFile

subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}