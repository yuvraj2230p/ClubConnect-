from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.views.static import serve
import mimetypes
from django.http import HttpResponse, FileResponse

def cors_static_serve(request, path, document_root=None, show_indexes=False):
    response = serve(request, path, document_root=document_root, show_indexes=show_indexes)
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response["Access-Control-Allow-Headers"] = "*"
    return response

def serve_flutter_web(request, path=''):
    candidates = [
        settings.BASE_DIR / 'flutter_web',
        settings.BASE_DIR.parent / 'mobile' / 'build' / 'web',
    ]
    flutter_web_dir = next((c for c in candidates if c.is_dir() and (c / 'index.html').is_file()), candidates[0])
    clean_path = path.lstrip('/')
    if clean_path:
        requested_file = flutter_web_dir / clean_path
        if requested_file.is_file():
            content_type, _ = mimetypes.guess_type(str(requested_file))
            if clean_path.endswith('.wasm'):
                content_type = 'application/wasm'
            elif clean_path.endswith('.js'):
                content_type = 'application/javascript'
            response = FileResponse(open(requested_file, 'rb'), content_type=content_type)
            response["Access-Control-Allow-Origin"] = "*"
            return response

    index_file = flutter_web_dir / 'index.html'
    if index_file.is_file():
        response = FileResponse(open(index_file, 'rb'), content_type='text/html')
        response["Access-Control-Allow-Origin"] = "*"
        return response
    return HttpResponse("Flutter Web build not found. Please run 'flutter build web'.", status=404)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
    path('api/clubs/', include('clubs.urls')),
    path('api/events/', include('events.urls')),
    re_path(r'^static/(?P<path>.*)$', cors_static_serve, {'document_root': settings.STATICFILES_DIRS[0]}),
    re_path(r'^(?P<path>.*)$', serve_flutter_web),
]
