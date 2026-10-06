from flask import jsonify


def success_response(data=None, message="Success", status=200):
    return jsonify({"success": True, "message": message, "data": data}), status


def error_response(message="Error", status=400, errors=None):
    payload = {"success": False, "message": message}
    if errors:
        payload["errors"] = errors
    return jsonify(payload), status
