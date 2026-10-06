from flask import Blueprint
from flask_jwt_extended import jwt_required
from sqlalchemy import text
from app.extensions import db
from app.utils.response import success_response, error_response


dbms_bp = Blueprint("dbms", __name__, url_prefix="/api/dbms")

SAFE_OPERATIONS = {
    "active_studies": "SELECT * FROM active_studies",
    "participant_research_summary": "SELECT * FROM participant_research_summary LIMIT 200",
    "biomarker_summary": "SELECT * FROM biomarker_summary LIMIT 200",
    "researcher_activity": "SELECT * FROM researcher_activity LIMIT 200",
    "experiment_summary": "SELECT * FROM experiment_summary LIMIT 200",
}


@dbms_bp.get("/operations")
@jwt_required()
def list_operations():
    return success_response(list(SAFE_OPERATIONS.keys()))


@dbms_bp.get("/operations/<operation_name>")
@jwt_required()
def run_safe_operation(operation_name):
    sql = SAFE_OPERATIONS.get(operation_name)
    if not sql:
        return error_response("Unsupported operation", 400)

    rows = db.session.execute(text(sql)).mappings().all()
    return success_response([dict(r) for r in rows])
