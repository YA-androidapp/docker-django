from allauth.account.adapter import DefaultAccountAdapter


class AccountAdapter(DefaultAccountAdapter):

    def save_user(self, request, user, form, commit=True):
        """
        This is called when saving user via allauth registration.
        We override this to set additional data on user object.
        """
        user = super(AccountAdapter, self).save_user(
            request, user, form, commit=False)
        user.age = form.cleaned_data.get('age')
        user.save()
