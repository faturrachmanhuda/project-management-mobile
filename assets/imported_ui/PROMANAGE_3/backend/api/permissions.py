from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to access it.
    """

    def has_object_permission(self, request, view, obj):
        # Check if object has user attribute
        if hasattr(obj, 'user'):
            return obj.user == request.user
        # For Work objects, check through project
        elif hasattr(obj, 'project'):
            return obj.project.user == request.user
        # For Activity objects, check through work.project
        elif hasattr(obj, 'work'):
            return obj.work.project.user == request.user
        # For ActivityFile objects, check through activity.work.project
        elif hasattr(obj, 'activity'):
            return obj.activity.work.project.user == request.user
        return False
