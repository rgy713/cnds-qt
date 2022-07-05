QT += core gui sql widgets qml quick

android {
    QT += androidextras
}

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

INCLUDEPATH += $$PWD/src

#contains(ANDROID_TARGET_ARCH,arm64-v8a) {
#    ANDROID_EXTRA_LIBS = \
#        $$PWD/openssl/arm64-v8a/libcrypto.so \
#        $$PWD/openssl/arm64-v8a/libssl.so
#}

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/openssl/armeabi-v7a/libcrypto.so \
        $$PWD/openssl/armeabi-v7a/libssl.so
}

contains(ANDROID_TARGET_ARCH,armeabi) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/openssl/armeabi/libcrypto.so \
        $$PWD/openssl/armeabi/libssl.so
}

#contains(ANDROID_TARGET_ARCH,x86_64) {
#    ANDROID_EXTRA_LIBS = \
#        $$PWD/openssl/x86_64/libcrypto.so \
#        $$PWD/openssl/x86_64/libssl.so
#}

contains(ANDROID_TARGET_ARCH,x86) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/openssl/x86/libcrypto.so \
        $$PWD/openssl/x86/libssl.so
}

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
    src/ServiceManager.cpp \
    src/Common.cpp \
    src/DBManager.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

android {
    DISTFILES += \
        android/AndroidManifest.xml \
        android/res/values/libs.xml \
        android/build.gradle

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    myDataDir.files += $$files($$PWD/data/cnds.db)
    myDataDir.files += $$files($$PWD/data/config.ini)
    myDataDir.path = $$QMAKE_TARGET/assets/data
    INSTALLS += myDataDir
}

HEADERS += \
    src/ServiceManager.h \
    src/Common.h \
    src/DBManager.h

