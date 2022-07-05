#include <QSettings>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlDriver>
#include <QSqlError>
#include <QDebug>
#include <QDir>
#include <QCryptographicHash>
#include <QDateTime>

#include "DBManager.h"
#include "Common.h"

DBManager* DBManager::m_instance = Q_NULLPTR;

DBManager::DBManager(QObject *parent) : QObject(parent)
{
    initDatabases();
}

DBManager::~DBManager()
{
    {
        QSqlDatabase cnds_db = QSqlDatabase::database();
        cnds_db.close();
    }
}

DBManager *DBManager::instance()
{
    if (m_instance == Q_NULLPTR)
    {
        m_instance = new DBManager();
    }
    return m_instance;
}

void DBManager::deleteInstance()
{
    delete m_instance;
    m_instance = Q_NULLPTR;
}

bool DBManager::initDatabases()
{
#ifdef Q_OS_ANDROID
    QString cndsDBPath = "./cnds.db3";
    if (!QFile::exists(cndsDBPath)) {
        QFile dfile("assets:/data/cnds.db");
        if (dfile.exists()) {
            dfile.copy(cndsDBPath);
            QFile::setPermissions(cndsDBPath, QFile::WriteOwner | QFile::ReadOwner);
        }
    }
#else
    QString cndsDBPath = QDir::currentPath() + "/data/cnds.db";
#endif

    QSqlDatabase cnds_db = QSqlDatabase::addDatabase("QSQLITE");
    cnds_db.setDatabaseName(cndsDBPath);

    if (!cnds_db.open()) {
        qDebug() << "No Open Database";

        return false;
    }

    return true;
}

QVariantMap DBManager::login(QString p_userId, QString p_userPwd)
{
    QVariantMap ret;

    if (p_userId.isEmpty() || p_userPwd.isEmpty()) {
        return ret;
    }

    QString pwd = QCryptographicHash::hash(p_userPwd.toLatin1(), QCryptographicHash::Md5).toHex();

    QSqlQuery query;
    query.prepare("SELECT * FROM user WHERE user_id = :user_id AND password = :password AND is_active = 1");
    query.bindValue(":user_id", p_userId);
    query.bindValue(":password", pwd);
    if (query.exec()) {
        if (query.next()) {
            ret["id"] = query.value("id");
            ret["name"] = query.value("name");
            ret["user_id"] = query.value("user_id");
            ret["role_name"] = query.value("role_name");
            ret["role"] = query.value("role");
        }
    }
    else {
        qDebug() << query.lastError().text();
    }

    return ret;
}

bool DBManager::setUserRoleList(QVariantList p_roleList)
{
    QListIterator<QVariant> i(p_roleList);

    QStringList setValueList;

    while (i.hasNext()) {
        QVariantMap userRole = i.next().toMap();

        QStringList valueList;

        QString id = userRole.value("User_DBKey").toString();
        QString name = userRole.value("UserName").toString();
        QString user_id = userRole.value("UserLoginID").toString();
        QString password = userRole.value("LoginPassword").toString();
        QString is_active = userRole.value("IsActive").toString();
        QString role_name = userRole.value("RoleName").toString();
        QVariantList role = userRole.value("role").toList();

        QStringList departmentIds;
        QListIterator<QVariant> k(role);
        while (k.hasNext()) {
            QString departmentId = k.next().toMap().value("Department_DBKey").toString();

            departmentIds << departmentId;
        }

        valueList << id
                  << QString("'%1'").arg(name)
                  << QString("'%1'").arg(user_id)
                  << QString("'%1'").arg(password)
                  << (is_active.isEmpty() ? "NULL" : is_active)
                  << QString("'%1'").arg(role_name)
                  << (departmentIds.count() > 0 ? QString("'%1'").arg(departmentIds.join(",")) : "NULL");

        setValueList << QString("(%1)").arg(valueList.join(","));
    }

    if (setValueList.count() > 0) {
        QString insertSql = QString("INSERT INTO user(id, name, user_id, password, is_active, role_name, role) VALUES %1 ")
                                .arg(setValueList.join(","));

        QSqlQuery insertQuery;
        insertQuery.prepare(insertSql);
        if (insertQuery.exec()) {
            return true;
        }
        else {
            qDebug() << insertQuery.lastError().text();
        }
    }

    return false;
}

QVariantList DBManager::getUserRoleList()
{
    QVariantList ret;

    QString getSql = QString("SELECT id, name, user_id, is_active, role_name, role FROM user WHERE id > 0");

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            QVariantMap userRole;

            userRole["id"] = getQuery.value("id");
            userRole["name"] = getQuery.value("name");
            userRole["user_id"] = getQuery.value("user_id");
            userRole["is_active"] = getQuery.value("is_active");
            userRole["role_name"] = getQuery.value("role_name");
            userRole["role"] = getQuery.value("role");

            ret << userRole;
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

bool DBManager::setDepartmentList(QVariantList p_departmentList)
{
    QListIterator<QVariant> i(p_departmentList);

    QStringList setValueList;

    while (i.hasNext()) {
        QVariantMap department = i.next().toMap();

        QStringList valueList;

        QString id = department.value("Department_DBKey").toString();
        QString name = department.value("DepartmentName").toString();

        valueList << id
                  << QString("'%1'").arg(name);

        setValueList << QString("(%1)").arg(valueList.join(","));
    }

    if (setValueList.count() > 0) {
        QString insertSql = QString("INSERT INTO department(id, name) VALUES %1 ")
                                .arg(setValueList.join(","));

        QSqlQuery insertQuery;
        insertQuery.prepare(insertSql);
        if (insertQuery.exec()) {
            return true;
        }
        else {
            qDebug() << insertQuery.lastError().text();
        }
    }

    return false;
}

QVariantList DBManager::getDepartmentList()
{
    QVariantList ret;

    QString getSql = QString("SELECT id, name FROM department");

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            QVariantMap department;

            department["id"] = getQuery.value("id");
            department["name"] = getQuery.value("name");

            ret << department;
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

QVariantList DBManager::getDiseaseList()
{
    QVariantList ret;

    QString getSql = QString("SELECT id, code, name FROM disease");

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            QVariantMap disease;

            disease["id"] = getQuery.value("id");
            disease["code"] = getQuery.value("code");
            disease["name"] = getQuery.value("name");

            ret << disease;
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

bool DBManager::setPatientList(QVariantList p_patientList)
{
    QListIterator<QVariant> i(p_patientList);

    QStringList setValueList;

    while (i.hasNext()) {
        QVariantMap patient = i.next().toMap();

        QStringList valueList;

        QString id = patient.value("PatientHospitalize_DBKey").toString();
        QString number = patient.value("PatientNo").toString();
        QString hospitalization_number = patient.value("HospitalizationNumber").toString();
        QString name = patient.value("PatientName").toString();
        QString height = patient.value("Height").toString();
        QString weight = patient.value("Weight").toString();
        QString department_id = patient.value("Department_DBKey").toString();
        QString department_name = patient.value("DepartmentName").toString();
        QString bed_code = patient.value("BedCode").toString();
        QString disease_name = patient.value("DiseaseName").toString();
        QString in_hospital_date = patient.value("InHospitalData").toString();
        QString gender = patient.value("Gender").toString();
        QString age = patient.value("Age").toString();
        QString therapy_start_time = patient.value("TherapyStartTime").toString();
        QString nrs2002 = patient.value("NRS2002").toString();
        QString next_screening_date = patient.value("NextScreeningDate").toString();
        QString after_ck = patient.value("afterCk").toString();
        QString before_ck = patient.value("beforeCk").toString();

        valueList << id
                  << QString("'%1'").arg(number)
                  << QString("'%1'").arg(hospitalization_number)
                  << QString("'%1'").arg(name)
                  << (height.isEmpty() ? "NULL" : height)
                  << (weight.isEmpty() ? "NULL" : weight)
                  << (department_id.isEmpty() ? "NULL" : department_id)
                  << QString("'%1'").arg(department_name)
                  << QString("'%1'").arg(bed_code)
                  << QString("'%1'").arg(disease_name)
                  << (in_hospital_date.isEmpty() ? "NULL" : QString::number(QDateTime::fromString(in_hospital_date, "yyyy-MM-dd hh:mm:ss").toMSecsSinceEpoch()))
                  << (gender == "M" ? "0" : "1")
                  << (age.isEmpty() ? "NULL" : age)
                  << (therapy_start_time.isEmpty() ? "NULL" : QString::number(QDateTime::fromString(therapy_start_time, "yyyy-MM-dd hh:mm:ss").toMSecsSinceEpoch()))
                  << (nrs2002.isEmpty() ? "NULL" : nrs2002)
                  << (next_screening_date.isEmpty() ? "NULL" : QString::number(QDateTime::fromString(next_screening_date, "yyyy-MM-dd hh:mm:ss").toMSecsSinceEpoch()))
                  << QString("'%1'").arg(after_ck)
                  << QString("'%1'").arg(before_ck);

        setValueList << QString("(%1)").arg(valueList.join(","));
    }

    if (setValueList.count() > 0) {
        QString insertSql = QString("INSERT INTO patient( "
                                    "id, "
                                    "number, "
                                    "hospitalization_number, "
                                    "name, "
                                    "height, "
                                    "weight, "
                                    "department_id, "
                                    "department_name, "
                                    "bed_code, "
                                    "disease_name, "
                                    "in_hospital_date, "
                                    "gender, "
                                    "age, "
                                    "therapy_start_time, "
                                    "nrs2002, "
                                    "next_screening_date, "
                                    "after_ck, "
                                    "before_ck) VALUES %1 ")
                                .arg(setValueList.join(","));

        QSqlQuery insertQuery;
        insertQuery.prepare(insertSql);
        if (insertQuery.exec()) {
            return true;
        }
        else {
            qDebug() << insertQuery.lastError().text();
        }
    }

    return false;
}

QVariantList DBManager::getPatientList(QString p_departmentList)
{
    QVariantList ret;

    QString getSql = QString("SELECT * FROM patient %1")
                    .arg(p_departmentList.split(",").count() > 0 ?
                       QString(" WHERE department_id IN (%1) ").arg(p_departmentList) : "");

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            QVariantMap patient;

            patient["id"] = getQuery.value("id");
            patient["number"] = getQuery.value("number");
            patient["hospitalization_number"] = getQuery.value("hospitalization_number");
            patient["name"] = getQuery.value("name");
            patient["height"] = getQuery.value("height");
            patient["weight"] = getQuery.value("weight");
            patient["department_id"] = getQuery.value("department_id");
            patient["department_name"] = getQuery.value("department_name");
            patient["bed_code"] = getQuery.value("bed_code");
            patient["disease_name"] = getQuery.value("disease_name");
            patient["in_hospital_date"] = getQuery.value("in_hospital_date");
            patient["gender"] = getQuery.value("gender");
            patient["age"] = getQuery.value("age");
            patient["therapy_start_time"] = getQuery.value("therapy_start_time");
            patient["nrs2002"] = getQuery.value("nrs2002");
            patient["next_screening_date"] = getQuery.value("next_screening_date");
            patient["after_ck"] = getQuery.value("after_ck");
            patient["before_ck"] = getQuery.value("before_ck");

            ret << patient;
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

QVariantList DBManager::searchPatientList(QString p_departmentList, QVariantMap p_searchParams)
{
    QVariantList ret;

    QStringList whereList;

    if (p_departmentList.split(",").count() > 0) {
        whereList << QString("department_id IN (%1)").arg(p_departmentList);
    }

    QString patientId = p_searchParams.value("id").toString();
    if (!patientId.isEmpty()) {
        whereList << QString("id LIKE '%%1%'").arg(patientId);
    }
    QString patientName = p_searchParams.value("name").toString();
    if (!patientName.isEmpty()) {
        whereList << QString("name LIKE '%%1%'").arg(patientName);
    }

    QString getSql = QString("SELECT patient.*, user.name AS user_name, nrs.submitted FROM patient "
                             "JOIN nrs2002 AS nrs ON nrs.patient_id = patient.id "
                             "JOIN user ON user.user_id = nrs.user_id "
                             "%1")
                    .arg(whereList.count() > 0 ? " WHERE " + whereList.join(" AND ") : "");

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            QVariantMap patient;

            patient["id"] = getQuery.value("id");
            patient["number"] = getQuery.value("number");
            patient["hospitalization_number"] = getQuery.value("hospitalization_number");
            patient["name"] = getQuery.value("name");
            patient["height"] = getQuery.value("height");
            patient["weight"] = getQuery.value("weight");
            patient["department_id"] = getQuery.value("department_id");
            patient["department_name"] = getQuery.value("department_name");
            patient["bed_code"] = getQuery.value("bed_code");
            patient["disease_name"] = getQuery.value("disease_name");
            patient["in_hospital_date"] = getQuery.value("in_hospital_date");
            patient["gender"] = getQuery.value("gender");
            patient["age"] = getQuery.value("age");
            patient["therapy_start_time"] = getQuery.value("therapy_start_time");
            patient["nrs2002"] = getQuery.value("nrs2002");
            patient["next_screening_date"] = getQuery.value("next_screening_date");
            patient["after_ck"] = getQuery.value("after_ck");
            patient["before_ck"] = getQuery.value("before_ck");

            patient["user_name"] = getQuery.value("user_name");
            patient["submitted"] = getQuery.value("submitted");

            ret << patient;
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

bool DBManager::setNRS2002(QString p_patientId, QString p_result, QString p_userId)
{
    bool ret = false;

    if (p_patientId.isEmpty()) {
        return ret;
    }

    QString updateSql = QString("INSERT INTO nrs2002 (patient_id, result, user_id) VALUES (%1, '%2', '%3') ")
            .arg(p_patientId)
            .arg(p_result)
            .arg(p_userId);

    QSqlQuery updateQuery;
    updateQuery.prepare(updateSql);
    if (updateQuery.exec()) {
        ret = true;
    }
    else {
        qDebug() << updateQuery.lastError().text();
    }

    return ret;
}

bool DBManager::setSubmittedNRS2002(QString p_patientId, bool p_submitted)
{
    bool ret = false;

    if (p_patientId.isEmpty()) {
        return ret;
    }

    QString updateSql = QString("UPDATE nrs2002 SET submitted = %1 WHERE patient_id = %2 ")
            .arg(p_submitted ? 1 : 0)
            .arg(p_patientId);

    QSqlQuery updateQuery;
    updateQuery.prepare(updateSql);
    if (updateQuery.exec()) {
        ret = true;
    }
    else {
        qDebug() << updateQuery.lastError().text();
    }

    return ret;
}

bool DBManager::setAllSubmittedNRS2002(QString p_userId, bool p_submitted)
{
    bool ret = false;

    if (p_userId.isEmpty()) {
        return ret;
    }

    QString updateSql = QString("UPDATE nrs2002 SET submitted = %1 WHERE user_id = %2 ")
            .arg(p_submitted ? 1 : 0)
            .arg(p_userId);

    QSqlQuery updateQuery;
    updateQuery.prepare(updateSql);
    if (updateQuery.exec()) {
        ret = true;
    }
    else {
        qDebug() << updateQuery.lastError().text();
    }

    return ret;
}

QString DBManager::getNRS2002(QString p_patientId)
{
    QString ret;

    if (p_patientId.isEmpty()) {
        return ret;
    }

    QString getSql = QString("SELECT result FROM nrs2002 WHERE patient_id = %1").arg(p_patientId);

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        if (getQuery.next()) {
            ret = getQuery.value("result").toString();
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}

QVariantList DBManager::getAllNRS2002(QString p_userId)
{
    QVariantList ret;

    if (p_userId.isEmpty()) {
        return ret;
    }

    QString getSql = QString("SELECT result FROM nrs2002 WHERE user_id = %1").arg(p_userId);

    QSqlQuery getQuery;
    getQuery.prepare(getSql);
    if (getQuery.exec()) {
        while (getQuery.next()) {
            ret << getQuery.value("result").toString();
        }
    }
    else {
        qDebug() << getQuery.lastError().text();
    }

    return ret;
}
