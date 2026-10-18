from django.urls import path
from .views import SIMLoginView, CurrentUserView, ShowcaseSlidesView

urlpatterns = [
    path('sim-login/', SIMLoginView.as_view(), name='sim_login'),
    path('me/', CurrentUserView.as_view(), name='current_user'),
    path('showcase-slides/', ShowcaseSlidesView.as_view(), name='showcase_slides'),
]
