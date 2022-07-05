#ifndef COMMON_H
#define COMMON_H

#include <QObject>
#include <QVariant>

bool openStringFile(QString p_filePath, QString& p_result);

class ConfigSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString hospitalName READ hospitalName WRITE setHospitalName NOTIFY hospitalNameChanged)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)

public:
    explicit ConfigSettings(QObject *parent = 0);

    static ConfigSettings* instance();
    static void deleteInstance();

    QString configPath();

    void setValue(QString p_name, QVariant p_value);

    QString host() const;
    void setHost(const QString &host);

    QString hospitalName() const;
    void setHospitalName(const QString &hospitalName);

signals:
    void hospitalNameChanged(QString p_hosptialName);
    void hostChanged(QString p_host);

public slots:

private:
    static ConfigSettings* m_instance;

    QString m_hospitalName;
    QString m_host;
};

#endif // COMMON_H
