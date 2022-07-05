#include <QFile>
#include <QTextStream>
#include <QSettings>
#include <QDir>
#include <QFile>
#include <QDebug>

#include "Common.h"

bool openStringFile(QString p_filePath, QString& p_result)
{
    bool w_ret = false;

    QFile file(p_filePath);

    if (file.open( QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        in.setCodec("UTF-8");
        p_result = in.read(file.size());
        file.close();
        w_ret = true;
    }
    else
    {
        p_result.clear();
    }

    return w_ret;
}

ConfigSettings* ConfigSettings::m_instance = Q_NULLPTR;

ConfigSettings::ConfigSettings(QObject *parent) : QObject(parent)
{
    QSettings settings(configPath(), QSettings::IniFormat);
    settings.setIniCodec("UTF-8");

    m_hospitalName = settings.value("hospital_name").toString();
    m_host = settings.value("host").toString();
}

QString ConfigSettings::configPath()
{
#ifdef Q_OS_ANDROID
    QString configPath = "./config.ini";
    if (!QFile::exists(configPath)) {
        QFile dfile("assets:/data/config.ini");
        if (dfile.exists()) {
            dfile.copy(configPath);
            QFile::setPermissions(configPath, QFile::WriteOwner | QFile::ReadOwner);
        }
    }
#else
    QString configPath = QDir::currentPath() + "/data/config.ini";
#endif

    return configPath;
}

ConfigSettings *ConfigSettings::instance()
{
    if (m_instance == Q_NULLPTR)
    {
        m_instance = new ConfigSettings();
    }
    return m_instance;
}

void ConfigSettings::deleteInstance()
{
    delete m_instance;
    m_instance = Q_NULLPTR;
}

void ConfigSettings::setValue(QString p_name, QVariant p_value)
{
    QSettings settings(configPath(), QSettings::IniFormat);
    settings.setIniCodec("UTF-8");

    settings.setValue(p_name, p_value);
    settings.sync();
}

QString ConfigSettings::host() const
{
    return m_host;
}

void ConfigSettings::setHost(const QString &host)
{
    if (m_host != host) {
        m_host = host;
        setValue("host", host);
        emit hostChanged(host);
    }
}

QString ConfigSettings::hospitalName() const
{
    return m_hospitalName;
}

void ConfigSettings::setHospitalName(const QString &hospitalName)
{
    if (m_hospitalName != hospitalName) {
        m_hospitalName = hospitalName;
        setValue("hospital_name", hospitalName);
        emit hospitalNameChanged(hospitalName);
    }
}
