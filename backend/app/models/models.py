from datetime import datetime, date
from sqlalchemy import CheckConstraint, UniqueConstraint, ForeignKey
from app.extensions import db


class TimestampMixin:
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )


class Role(db.Model):
    __tablename__ = "roles"

    role_id = db.Column(db.Integer, primary_key=True)
    role_name = db.Column(db.String(80), unique=True, nullable=False)


class User(TimestampMixin, db.Model):
    __tablename__ = "users"

    user_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role_id = db.Column(db.Integer, ForeignKey("roles.role_id"), nullable=False)
    is_active = db.Column(db.Boolean, default=True, nullable=False)

    role = db.relationship("Role", backref="users")


class Department(TimestampMixin, db.Model):
    __tablename__ = "departments"

    department_id = db.Column(db.Integer, primary_key=True)
    department_name = db.Column(db.String(120), unique=True, nullable=False)
    location = db.Column(db.String(120), nullable=False)


class Researcher(TimestampMixin, db.Model):
    __tablename__ = "researchers"

    researcher_id = db.Column(db.Integer, primary_key=True)
    researcher_code = db.Column(db.String(20), unique=True, nullable=False)
    first_name = db.Column(db.String(80), nullable=False)
    last_name = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    specialization = db.Column(db.String(120), nullable=False)
    department_id = db.Column(db.Integer, ForeignKey("departments.department_id"), nullable=False)
    user_id = db.Column(db.Integer, ForeignKey("users.user_id"), unique=True)


class Study(TimestampMixin, db.Model):
    __tablename__ = "studies"

    study_id = db.Column(db.Integer, primary_key=True)
    study_code = db.Column(db.String(20), unique=True, nullable=False)
    title = db.Column(db.String(255), nullable=False)
    objective = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(30), nullable=False, default="planned")
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date)
    principal_investigator_id = db.Column(
        db.Integer, ForeignKey("researchers.researcher_id"), nullable=False
    )

    __table_args__ = (
        CheckConstraint("status in ('planned','active','completed','paused','cancelled')", name="chk_study_status"),
    )


class StudyResearcher(db.Model):
    __tablename__ = "study_researchers"

    study_id = db.Column(db.Integer, ForeignKey("studies.study_id"), primary_key=True)
    researcher_id = db.Column(
        db.Integer, ForeignKey("researchers.researcher_id"), primary_key=True
    )
    assigned_role = db.Column(db.String(100), nullable=False)
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)


class Disease(TimestampMixin, db.Model):
    __tablename__ = "diseases"

    disease_id = db.Column(db.Integer, primary_key=True)
    disease_code = db.Column(db.String(20), unique=True, nullable=False)
    disease_name = db.Column(db.String(120), unique=True, nullable=False)
    category = db.Column(db.String(120), nullable=False)


class Participant(TimestampMixin, db.Model):
    __tablename__ = "participants"

    participant_id = db.Column(db.Integer, primary_key=True)
    participant_code = db.Column(db.String(20), unique=True, nullable=False)
    disease_id = db.Column(db.Integer, ForeignKey("diseases.disease_id"), nullable=False)
    study_id = db.Column(db.Integer, ForeignKey("studies.study_id"), nullable=False)
    enrollment_date = db.Column(db.Date, nullable=False)
    birth_date = db.Column(db.Date, nullable=False)
    sex = db.Column(db.String(20), nullable=False)
    status = db.Column(db.String(20), nullable=False, default="enrolled")

    __table_args__ = (
        CheckConstraint("sex in ('male','female','other','undisclosed')", name="chk_participant_sex"),
    )


class Sample(TimestampMixin, db.Model):
    __tablename__ = "samples"

    sample_id = db.Column(db.Integer, primary_key=True)
    sample_code = db.Column(db.String(20), unique=True, nullable=False)
    participant_id = db.Column(
        db.Integer, ForeignKey("participants.participant_id"), nullable=False
    )
    study_id = db.Column(db.Integer, ForeignKey("studies.study_id"), nullable=False)
    sample_type = db.Column(db.String(60), nullable=False)
    collection_date = db.Column(db.Date, nullable=False)
    storage_location = db.Column(db.String(120), nullable=False)
    status = db.Column(db.String(20), nullable=False, default="stored")


class Experiment(TimestampMixin, db.Model):
    __tablename__ = "experiments"

    experiment_id = db.Column(db.Integer, primary_key=True)
    experiment_code = db.Column(db.String(20), unique=True, nullable=False)
    study_id = db.Column(db.Integer, ForeignKey("studies.study_id"), nullable=False)
    sample_id = db.Column(db.Integer, ForeignKey("samples.sample_id"), nullable=False)
    researcher_id = db.Column(db.Integer, ForeignKey("researchers.researcher_id"), nullable=False)
    experiment_type = db.Column(db.String(100), nullable=False)
    status = db.Column(db.String(20), nullable=False, default="queued")
    experiment_date = db.Column(db.Date, nullable=False)
    success_score = db.Column(db.Numeric(5, 2), nullable=False, default=0)


class Biomarker(TimestampMixin, db.Model):
    __tablename__ = "biomarkers"

    biomarker_id = db.Column(db.Integer, primary_key=True)
    biomarker_code = db.Column(db.String(20), unique=True, nullable=False)
    biomarker_name = db.Column(db.String(120), unique=True, nullable=False)
    unit = db.Column(db.String(20), nullable=False)
    reference_min = db.Column(db.Numeric(10, 3), nullable=False)
    reference_max = db.Column(db.Numeric(10, 3), nullable=False)


class ExperimentBiomarker(db.Model):
    __tablename__ = "experiment_biomarkers"

    experiment_id = db.Column(
        db.Integer, ForeignKey("experiments.experiment_id"), primary_key=True
    )
    biomarker_id = db.Column(db.Integer, ForeignKey("biomarkers.biomarker_id"), primary_key=True)
    measured_value = db.Column(db.Numeric(12, 4), nullable=False)
    measured_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)


class ResearchResult(TimestampMixin, db.Model):
    __tablename__ = "research_results"

    result_id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(
        db.Integer, ForeignKey("experiments.experiment_id"), nullable=False
    )
    finding = db.Column(db.Text, nullable=False)
    conclusion = db.Column(db.Text, nullable=False)
    confidence_score = db.Column(db.Numeric(5, 2), nullable=False)


class Publication(TimestampMixin, db.Model):
    __tablename__ = "publications"

    publication_id = db.Column(db.Integer, primary_key=True)
    publication_code = db.Column(db.String(20), unique=True, nullable=False)
    title = db.Column(db.String(255), nullable=False)
    journal = db.Column(db.String(255), nullable=False)
    publication_date = db.Column(db.Date, nullable=False)
    doi = db.Column(db.String(120), unique=True)


class StudyPublication(db.Model):
    __tablename__ = "study_publications"

    study_id = db.Column(db.Integer, ForeignKey("studies.study_id"), primary_key=True)
    publication_id = db.Column(
        db.Integer, ForeignKey("publications.publication_id"), primary_key=True
    )


class AuditLog(db.Model):
    __tablename__ = "audit_logs"

    audit_id = db.Column(db.BigInteger, primary_key=True)
    table_name = db.Column(db.String(80), nullable=False)
    record_id = db.Column(db.String(80), nullable=False)
    action = db.Column(db.String(20), nullable=False)
    actor = db.Column(db.String(120), nullable=False)
    changed_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    details = db.Column(db.JSON)
