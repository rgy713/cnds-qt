#ifndef SERVICEMANAGER_H
#define SERVICEMANAGER_H

#include <QObject>
#include <QVariant>
#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>

class ServiceManager : public QObject
{
    Q_OBJECT
public:
    explicit ServiceManager(QObject *parent = 0);

    static ServiceManager* instance();
    static void deleteInstance();

    Q_INVOKABLE bool isOnline();

    Q_INVOKABLE void request(QString p_serviceName, QVariantMap p_serviceParams);

signals:
    void response(QString p_serviceName, QVariantMap p_result);

public slots:
    void acceptResponse();

private:
    static ServiceManager           *m_instance;
    QNetworkAccessManager           *netAccessManager;
    QNetworkConfigurationManager    m_connectChecker;

    QVariantMap m_services;

};

#endif // SERVICEMANAGER_H
