from django.views import generic


class ProfileView(generic.TemplateView):
    template_name = 'profile.html'


class WelcomeView(generic.TemplateView):
    template_name = 'welcome.html'
