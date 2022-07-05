#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QVariant>

class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = 0);
    ~DBManager();

    static DBManager* instance();
    static void deleteInstance();

    bool initDatabases();

    Q_INVOKABLE QVariantMap     login(QString p_userId, QString p_userPwd);
    Q_INVOKABLE bool            setUserRoleList(QVariantList p_roleList);
    Q_INVOKABLE QVariantList    getUserRoleList();
    Q_INVOKABLE bool            setDepartmentList(QVariantList p_departmentList);
    Q_INVOKABLE QVariantList    getDepartmentList();
    Q_INVOKABLE QVariantList    getDiseaseList();
    Q_INVOKABLE bool            setPatientList(QVariantList p_patientList);
    Q_INVOKABLE QVariantList    getPatientList(QString p_departmentList);
    Q_INVOKABLE QVariantList    searchPatientList(QString p_departmentList, QVariantMap p_searchParams);
    Q_INVOKABLE QString         getNRS2002(QString p_patientId);
    Q_INVOKABLE QVariantList    getAllNRS2002(QString p_userId);
    Q_INVOKABLE bool            setNRS2002(QString p_patientId, QString p_result, QString p_userId);
    Q_INVOKABLE bool            setSubmittedNRS2002(QString p_patientId, bool p_submitted);
    Q_INVOKABLE bool            setAllSubmittedNRS2002(QString p_userId, bool p_submitted);

signals:

public slots:

private:
    static DBManager* m_instance;
};

#endif // DBMANAGER_H
