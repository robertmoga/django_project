from django.contrib.auth.forms import UserCreationForm
from django import forms

from django.contrib.auth.models import User
from users.models import Profile


class UserRegistrationForm(UserCreationForm):
    email = forms.EmailInput()

    class Meta:
        model = User
        fields = ['username', 'email', 'password1', 'password2']


class UserUpdateForm(forms.ModelForm):
    email = forms.EmailInput() # why do we have this ?

    class Meta:
        model = User
        fields = ['username', 'email']


class ProfileUpdateForm(forms.ModelForm):
    email = forms.EmailInput()

    class Meta:
        model = Profile
        fields = ['image']