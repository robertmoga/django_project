from django.shortcuts import render
from django.http import HttpResponse

posts = [
    {
        'title': 'Post1',
        'author': 'Gustav',
        'date': '23 Aug 1944',
        'content': 'super content'
    },
    {
        'title': 'Post2',
        'author': 'Janeta',
        'date': '14 Feb 1998',
        'content': 'Rav4'
    }

]

def home(request):
    context = {'posts': posts}
    return render(request, 'blog/home.html', context)

def about(request):
    return render(request, 'blog/about.html', {'title': 'About'})