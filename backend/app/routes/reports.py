import csv
import io
from flask import Blueprint, Response
from flask_jwt_extended import jwt_required
from app.models.models import Study, Researcher, Participant, Disease, Sample, Experiment, Biomarker, ResearchResult, Publication
from app.services.crud_service import model_to_dict
from app.utils.response import error_response


reports_bp = Blueprint("reports", __name__, url_prefix="/api/reports")

RESOURCES = {
    "studies": Study,
    "researchers": Researcher,
    "participants": Participant,
    "diseases": Disease,
    "samples": Sample,
    "experiments": Experiment,
    "biomarkers": Biomarker,
    "results": ResearchResult,
    "publications": Publication,
}


@reports_bp.get("/export/<resource>.csv")
@jwt_required()
def export_csv(resource):
    model = RESOURCES.get(resource)
    if model is None:
        return error_response("Unsupported export resource", 400)

    rows = [model_to_dict(x) for x in model.query.limit(5000).all()]
    output = io.StringIO()
    if rows:
        writer = csv.DictWriter(output, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    else:
        output.write("no_data\n")

    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": f"attachment; filename={resource}.csv"},
    )
