from django.urls import path
from .views import (
    SIMLoginView, CurrentUserView, ShowcaseSlidesView,
    IDCardScanLoginView, VerifyStudentIDCardView, ExtractIDCardPhotoView
)

urlpatterns = [
    path('sim-login/', SIMLoginView.as_view(), name='sim_login'),
    path('id-card-scan/', IDCardScanLoginView.as_view(), name='id_card_scan'),
    path('verify-id-card/', VerifyStudentIDCardView.as_view(), name='verify_id_card'),
    path('extract-id-card-photo/', ExtractIDCardPhotoView.as_view(), name='extract_id_card_photo'),
    path('me/', CurrentUserView.as_view(), name='current_user'),
    path('showcase-slides/', ShowcaseSlidesView.as_view(), name='showcase_slides'),
]
