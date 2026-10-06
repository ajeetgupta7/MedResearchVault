from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from app.middleware.rbac import roles_required
from app.services.crud_service import list_items, get_item, create_item, update_item, delete_item, model_to_dict
from app.models.models import (
    Study,
    Researcher,
    Participant,
    Disease,
    Sample,
    Experiment,
    Biomarker,
    ResearchResult,
    Publication,
)
from app.utils.response import success_response, error_response


crud_bp = Blueprint("crud", __name__, url_prefix="/api")

RESOURCES = {
    "studies": (Study, "study_id"),
    "researchers": (Researcher, "researcher_id"),
    "participants": (Participant, "participant_id"),
    "diseases": (Disease, "disease_id"),
    "samples": (Sample, "sample_id"),
    "experiments": (Experiment, "experiment_id"),
    "biomarkers": (Biomarker, "biomarker_id"),
    "results": (ResearchResult, "result_id"),
    "publications": (Publication, "publication_id"),
}


@crud_bp.get("/<resource>")
@jwt_required()
def list_resource(resource):
    if resource not in RESOURCES:
        return error_response("Unsupported resource", 404)
    model, _ = RESOURCES[resource]
    page = request.args.get("page", default=1, type=int)
    per_page = request.args.get("per_page", default=20, type=int)
    return success_response(list_items(model, page=page, per_page=per_page))


@crud_bp.get("/<resource>/<int:item_id>")
@jwt_required()
def get_resource(resource, item_id):
    if resource not in RESOURCES:
        return error_response("Unsupported resource", 404)
    model, _ = RESOURCES[resource]
    item = get_item(model, item_id)
    return success_response(model_to_dict(item))


@crud_bp.post("/<resource>")
@roles_required("Administrator", "Principal Investigator", "Research Assistant")
def create_resource(resource):
    if resource not in RESOURCES:
        return error_response("Unsupported resource", 404)
    model, _ = RESOURCES[resource]
    payload = request.get_json(silent=True) or {}
    item = create_item(model, payload)
    return success_response(model_to_dict(item), "Created", 201)


@crud_bp.put("/<resource>/<int:item_id>")
@roles_required("Administrator", "Principal Investigator", "Research Assistant")
def update_resource(resource, item_id):
    if resource not in RESOURCES:
        return error_response("Unsupported resource", 404)
    model, _ = RESOURCES[resource]
    item = get_item(model, item_id)
    payload = request.get_json(silent=True) or {}
    item = update_item(item, payload)
    return success_response(model_to_dict(item), "Updated")


@crud_bp.delete("/<resource>/<int:item_id>")
@roles_required("Administrator", "Principal Investigator")
def delete_resource(resource, item_id):
    if resource not in RESOURCES:
        return error_response("Unsupported resource", 404)
    model, _ = RESOURCES[resource]
    item = get_item(model, item_id)
    delete_item(item)
    return success_response(None, "Deleted", 200)
