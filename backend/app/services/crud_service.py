from sqlalchemy import inspect
from app.extensions import db


def model_to_dict(instance):
    return {c.key: getattr(instance, c.key) for c in inspect(instance).mapper.column_attrs}


def list_items(model, page=1, per_page=20):
    pagination = model.query.paginate(page=page, per_page=per_page, error_out=False)
    return {
        "items": [model_to_dict(item) for item in pagination.items],
        "pagination": {
            "page": pagination.page,
            "per_page": pagination.per_page,
            "total": pagination.total,
            "pages": pagination.pages,
        },
    }


def get_item(model, item_id):
    return model.query.get_or_404(item_id)


def create_item(model, payload):
    obj = model(**payload)
    db.session.add(obj)
    db.session.commit()
    return obj


def update_item(obj, payload):
    for key, value in payload.items():
        if hasattr(obj, key):
            setattr(obj, key, value)
    db.session.commit()
    return obj


def delete_item(obj):
    db.session.delete(obj)
    db.session.commit()
