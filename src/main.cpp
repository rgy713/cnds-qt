#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickWindow>

#include "Common.h"
#include "DBManager.h"
#include "ServiceManager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();

    context->setContextProperty("ConfigSettings", ConfigSettings::instance());
    context->setContextProperty("DBManager", DBManager::instance());
    context->setContextProperty("ServiceManager", ServiceManager::instance());

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QQuickWindow *mainWindow = qobject_cast<QQuickWindow*>(engine.rootObjects().first());

    mainWindow->showMaximized();

    int ret = app.exec();

    DBManager::deleteInstance();
    ServiceManager::deleteInstance();
    ConfigSettings::deleteInstance();

    return ret;
}
