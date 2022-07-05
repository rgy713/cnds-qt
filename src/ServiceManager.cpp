#include <QJsonDocument>
#include <QJsonObject>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QUrlQuery>
#include <QNetworkRequest>
#include <QNetworkReply>

#include "ServiceManager.h"

#include "Common.h"

ServiceManager* ServiceManager::m_instance = Q_NULLPTR;

ServiceManager::ServiceManager(QObject *parent) : QObject(parent)
{
    QString serviceListString;
    openStringFile(":/data/service.json", serviceListString);

    QJsonDocument jsonDoc  = QJsonDocument::fromJson(serviceListString.toUtf8());
    QJsonObject   jsonObject  = jsonDoc.object();
    m_services = jsonObject.toVariantMap();

    netAccessManager = new QNetworkAccessManager(this);
}

ServiceManager *ServiceManager::instance()
{
    if (m_instance == Q_NULLPTR)
    {
        m_instance = new ServiceManager();
    }
    return m_instance;
}

void ServiceManager::deleteInstance()
{
    delete m_instance;
    m_instance = Q_NULLPTR;
}

bool ServiceManager::isOnline()
{
    return m_connectChecker.isOnline();
}

void ServiceManager::request(QString p_serviceName, QVariantMap p_serviceParams)
{
    QString     serviceName = p_serviceName;

    QVariantMap result;
    result["success"] = false;

    if (serviceName.isEmpty()) {
        result["message"] =  "ERR_SERVICENAME_EMPTY";
        emit response(serviceName, result);
        return;
    }

    QVariantMap serviceInfo = m_services.value(serviceName).toMap();

    if (serviceInfo.isEmpty()) {
        result["message"] =  "ERR_UNKNOWN_SERVICE";
        emit response(serviceName, result);
        return;
    }

    QString host = ConfigSettings::instance()->host();
    QString path = serviceInfo.value("path").toString();

    if (host.isEmpty() || path.isEmpty() || isOnline() == false) {
        result["message"] =  "ERR_HOST_INVALID";
        emit response(serviceName, result);
        return;
    }

    QString servicePath = QString("http://%1/%2").arg(host).arg(path);

    //("GET", "POST", "PUT", "DELETE")
    QString     requestType = serviceInfo.value("type").toString();
    QStringList params      = serviceInfo.value("params").toString().split(",");

    QUrlQuery             queryParams;

    QNetworkAccessManager *manager = netAccessManager;

    QNetworkRequest       request;
    QNetworkReply         *reply   = NULL;

    QHttpMultiPart        *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    int paramsLength = params.count();

    for (int i = 0; i < paramsLength; i++) {
        QString paramElement = params.at(i);
        if (!paramElement.isEmpty()) {
            // "Q" - QueryParam, "F" - FormDataParam, "P" - PathParam
            QString paramType    = paramElement.left(1);
            QString paramName    = paramElement.remove(0, 1);
            QString paramValue   = p_serviceParams.value(paramName).toString().trimmed();

            if (!paramValue.isEmpty()) {
                if (paramType == "Q") {
                    queryParams.addQueryItem(paramName, paramValue);
                }
                else if (paramType == "F") {
                    QHttpPart textPart;
                    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, "form-data; name=\"" + paramName + "\"");
                    textPart.setBody(paramValue.toUtf8());
                    multiPart->append(textPart);
                }
                else if (paramType == "P") {
                    servicePath += ("/" + paramValue);
                }
            }
        }
    }

    QUrl    serviceUrl(servicePath);

    QVariantMap pathParams = serviceInfo.value("pathParams").toMap();
    QMapIterator<QString, QVariant> pi(pathParams);
    while (pi.hasNext()) {
        pi.next();

        QString key = pi.key();
        QString value = pi.value().toString();

        queryParams.addQueryItem(key, value);
    }

    if (!queryParams.isEmpty()) serviceUrl.setQuery(queryParams);

    if (requestType == "GET") {
        request.setUrl(QUrl::fromEncoded(serviceUrl.toEncoded()));
        reply = manager->get(request);
    }
    else if (requestType == "POST") {
        request.setUrl(QUrl::fromEncoded(serviceUrl.toEncoded()));
        reply = manager->post(request, multiPart);
    }
    else if (requestType == "PUT") {
        request.setUrl(QUrl::fromEncoded(serviceUrl.toEncoded()));
        reply = manager->put(request, multiPart);
    }
    else if (requestType == "DELETE") {
        request.setUrl(QUrl::fromEncoded(serviceUrl.toEncoded()));
        reply = manager->deleteResource(request);
    }

    reply->setObjectName(serviceName);
    multiPart->setParent(reply);

    connect(reply, SIGNAL(finished()), this, SLOT(acceptResponse()));
}

void ServiceManager::acceptResponse()
{
    QNetworkReply *reply      = qobject_cast<QNetworkReply *>(sender());

    if (reply) {
        QString serviceName  = reply->objectName();

        QVariantMap result;
        result["success"] = false;

        QByteArray tmp;
        if (reply->error() == QNetworkReply::NoError) {
            tmp = reply->readAll();

            QJsonDocument jsonDoc  = QJsonDocument::fromJson(tmp);
            if (!jsonDoc.isNull()) {
                QJsonObject   jsonObject  = jsonDoc.object();
                result = jsonObject.toVariantMap();
            }
        }
        else {
            QString errMsg = reply->errorString();

            if (reply->error() == QNetworkReply::OperationCanceledError) {
                errMsg = "ERR_OPERATION_CANCELLED";
            }
            else if (reply->error() == QNetworkReply::InternalServerError) {
                errMsg = "ERR_INTERNAL_SERVER_ERROR";
            }
            else if (reply->error() == QNetworkReply::HostNotFoundError) {
                errMsg = "ERR_HOST_NOT_FOUND_ERROR";
            }
            else if (reply->error() == QNetworkReply::UnknownContentError) {
                errMsg = "ERR_UNKOWN_CONTENT_ERROR";
            }
            else if (reply->error() == QNetworkReply::TimeoutError) {
                errMsg = "ERR_TIME_OUT_ERROR";
            }
            else {
                errMsg = "ERR_UNKNOWN";
            }

            result["message"] = errMsg;
        }

        reply -> deleteLater();

        emit response(serviceName, result);
    }
}
