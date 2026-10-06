from sqlalchemy import func
from app.extensions import db
from app.models.models import Study, Participant, Disease, Experiment, ExperimentBiomarker, Biomarker


def dashboard_summary():
    return {
        "studies": db.session.query(func.count(Study.study_id)).scalar(),
        "participants": db.session.query(func.count(Participant.participant_id)).scalar(),
        "experiments": db.session.query(func.count(Experiment.experiment_id)).scalar(),
        "biomarkers": db.session.query(func.count(Biomarker.biomarker_id)).scalar(),
    }


def studies_by_status():
    rows = db.session.query(Study.status, func.count(Study.study_id)).group_by(Study.status).all()
    return [{"status": s, "count": c} for s, c in rows]


def participants_by_disease():
    rows = (
        db.session.query(Disease.disease_name, func.count(Participant.participant_id))
        .join(Participant, Participant.disease_id == Disease.disease_id)
        .group_by(Disease.disease_name)
        .all()
    )
    return [{"disease": d, "count": c} for d, c in rows]


def experiments_by_type():
    rows = (
        db.session.query(Experiment.experiment_type, func.count(Experiment.experiment_id))
        .group_by(Experiment.experiment_type)
        .all()
    )
    return [{"type": t, "count": c} for t, c in rows]


def top_biomarkers(limit=10):
    rows = (
        db.session.query(Biomarker.biomarker_name, func.avg(ExperimentBiomarker.measured_value))
        .join(ExperimentBiomarker, ExperimentBiomarker.biomarker_id == Biomarker.biomarker_id)
        .group_by(Biomarker.biomarker_name)
        .order_by(func.avg(ExperimentBiomarker.measured_value).desc())
        .limit(limit)
        .all()
    )
    return [{"biomarker": b, "avg_value": float(v)} for b, v in rows]


def research_activity_over_time():
    rows = (
        db.session.query(func.date_trunc("month", Experiment.experiment_date), func.count(Experiment.experiment_id))
        .group_by(func.date_trunc("month", Experiment.experiment_date))
        .order_by(func.date_trunc("month", Experiment.experiment_date))
        .all()
    )
    return [{"month": str(month.date()), "count": count} for month, count in rows]
