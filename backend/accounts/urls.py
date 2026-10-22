from django.urls import path
from .views import SIMLoginView, CurrentUserView, ShowcaseSlidesView, IDCardScanLoginView

urlpatterns = [
    path('sim-login/', SIMLoginView.as_view(), name='sim_login'),
    path('id-card-scan/', IDCardScanLoginView.as_view(), name='id_card_scan'),
    path('me/', CurrentUserView.as_view(), name='current_user'),
    path('showcase-slides/', ShowcaseSlidesView.as_view(), name='showcase_slides'),
]
