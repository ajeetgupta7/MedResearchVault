from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from sqlalchemy import or_
from app.models.models import Study, Researcher, Participant, Experiment, Publication
from app.services.crud_service import model_to_dict
from app.utils.response import success_response


search_bp = Blueprint("search", __name__, url_prefix="/api")


@search_bp.get("/search")
@jwt_required()
def global_search():
    q = request.args.get("q", "").strip()
    if not q:
        return success_response([])

    studies = Study.query.filter(or_(Study.title.ilike(f"%{q}%"), Study.study_code.ilike(f"%{q}%"))).limit(5)
    researchers = Researcher.query.filter(
        or_(Researcher.first_name.ilike(f"%{q}%"), Researcher.last_name.ilike(f"%{q}%"), Researcher.researcher_code.ilike(f"%{q}%"))
    ).limit(5)
    participants = Participant.query.filter(Participant.participant_code.ilike(f"%{q}%")).limit(5)
    experiments = Experiment.query.filter(Experiment.experiment_code.ilike(f"%{q}%")).limit(5)
    publications = Publication.query.filter(Publication.title.ilike(f"%{q}%")).limit(5)

    return success_response(
        {
            "studies": [model_to_dict(x) for x in studies],
            "researchers": [model_to_dict(x) for x in researchers],
            "participants": [model_to_dict(x) for x in participants],
            "experiments": [model_to_dict(x) for x in experiments],
            "publications": [model_to_dict(x) for x in publications],
        }
    )
