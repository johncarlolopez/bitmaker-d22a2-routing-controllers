![Bitmaker](https://github.com/johncarlolopez/bitmaker-reference/blob/master/bitmakerlogo.svg)
# 02 - Intro to Routing and Controllers in Rails
### Wednesday, Jan 10th

## Generating the controller
___
Typically in a Rails app you will have one controller for each model. Often if you have any miscellaneous pages in your app that aren't associated with any particular model, you'll make an additional controller called PagesController to serve them. Since this app doesn't have any models we are just going to have a PagesController. To generate it, run:
```
rails g controller pages
```
You should see a new file called pages_controller.rb in app/controllers after running this command. It should look something like this:
```
class PagesController < ApplicationController
end
```
Notice how the name of our controller matches the name of the subdirectory inside app/views that contains all our erb files. One of the responsibilities of a controller is to decide which view to render/send back to the client. By default every Rails controller will look for erb files to render in the views subdirectory that matches its own name ("pages" in this case), so the naming matters here.

Let's make a git commit before going any further.

## Defining a Route
___
It's time to define our first route! Our goal is to make it so that when a user visits "localhost:3000/welcome", they see the contents of welcome.html.erb (found in app/views/pages/). We can do this by adding the following line of code to config/routes.rb, which is the one and only place for defining routes in a Rails app.
```
get '/welcome' => 'pages#welcome'
```
This line of code says that if a user makes a GET request to the URL "/welcome", Rails should run the welcome instance method inside the PagesController. The left side of the arrow (=>) in defines the route - both the request type (get) and URL ('/welcome') - and the right side of the arrow specifies which controller method (in the format controller_name#method_name) will handle requests to that route (in this case it's the welcome method inside the pages controller).

We don't have any instance methods inside our PagesController yet, so let's add one called welcome. You can leave the inside of the method blank for now.

If you try navigating to localhost:3000/welcome, you should now be presented with the welcome view. Why did this work even though we didn't add any meaningful code to our controller? The answer is that if you don't specifically render or redirect inside your controller method, the default behaviour of each controller method is to render a view that matches its name. In this case, because our method was called welcome, it found the corresponding erb file called welcome.html.erb.

We can override this behaviour by explicitly telling the controller what view to render. For example, if you add the following code inside the welcome method:
```
render :about
```
then when you navigate to localhost:3000/welcome, you should see the contents of about.html.erb instead of the welcome page. render :welcome would be the same as the default behaviour. Experiment with changing this code to point to different views. Note that the render method in Rails is equivalent to the erb method that you have been using in Sinatra.

We can set up multiple routes that make use of this single controller method. Let's have this controller method handle requests to our root URL as well by adding this line of code to routes.rb
```
get '/' => 'pages#welcome'
```
Now if you navigate to localhost:3000/ you should also be presented with the welcome page.

Now would be a good time to make another commit.

### Making the About Page Work
Let's make it possible to see the about.html.erb view by adding a new route and controller method. You can make up whatever URL you want for this route, but you should call your controller method about to take advantage of the default rendering behaviour (meaning take advantage of the fact that controller methods want to render erb files that share their names).

Make another commit once that's working.

### Making the Contest Page Work
Define another route and controller method to make it possible to see the contest.html.erb view, and then commit your changes.

## Instance Variables
___
Besides deciding which view to render, another of our controllers' responsibilities is setting up data (in instance variables) that will be used in your views.

If you look in the layout (app/views/layouts/application.html.erb) you'll see that the main heading (the h1 tag) of the page will be set to whatever is stored in the instance variable @header. We can give this variable a value in any or all of our instance methods. For example:
```
def welcome
  @header = "This is the welcome page"
end
```
Try giving different values to @header in your different instance methods and then visit each of you app's pages to see the effect.

Don't forget to commit!

## Defining Dynamic Routes
___
The next view we're going to tackle is kitten.html.erb, which should show the user a cat photo in the size of their choosing. We will allow the user to specify what size of image they would like by defining a dynamic route. Defining dynamic routes works similarly in Rails to how it's done in Sinatra:
```
get '/kitten/:size' => 'pages#kitten'
```
This code will apply to get requests to any URL that matches the pattern /kitten/some_number (localhost:3000/kitten/100, localhost:3000/kitten/500, localhost:3000/kitten/232, etc). Whatever number appears at the end of the URL will be stored in the params hash under the key :size. This way we can allow the user to specify what size of cat picture they would like to see on the kitten page!

Don't forget to create a kitten method in your controller to handle requests to this route.

Right now if you navigate to this page in your browser you should see an error message.

If you look in kitten.html.erb you'll see the code
```
 <%= image_tag @kitten_url %>
```
This will create an <img> tag with a src attribute set to whatever the value of @kitten_url is. Let's give that variable a value in our new kitten method using the "cats" category of the lorem pixel placeholder image service and the requested size that our user entered in the URL:
```
def kitten
  requested_size = params[:size]
  @kitten_url = "http://lorempixel.com/#{requested_size}/#{requested_size}/cats"
end
```
Now if you navigate to this page in your browser, you should see a picture of a cat from lorempixel.com. Changing the number in the URL should change the picture.

Once that's working you should commit your changes.

Keeping Your Code DRY with Before Filters
If you look in the views directory you'll see we also have a kittens.html.erb view that displays the same cat photo five times. Let's set up a dynamic route for this page. You can use whatever URL you want as long as you include a :size wildcard like we did for the previous route. Set it up to point to a kittens controller method.

This kittens method needs to set @kitten_url to a lorempixel URL, the same as we just did in the kitten method. So we could do this:

```
def kitten
  requested_size = params[:size]
  @kitten_url = "http://lorempixel.com/#{requested_size}/#{requested_size}/cats"
end

def kittens
  requested_size = params[:size]
  @kitten_url = "http://lorempixel.com/#{requested_size}/#{requested_size}/cats"
end
```
However, we want to avoid repeating code in multiple parts of our app. We should move this common code into its own method that gets called in both kitten and kittens:
```
def kitten
  set_kitten_url
end

def kittens
  set_kitten_url
end

def set_kitten_url
  requested_size = params[:size]
  @kitten_url = "http://lorempixel.com/#{requested_size}/#{requested_size}/cats"
end
```
We can simplify this code even further by setting up set_kitten_url as a before_action for both the kitten and kittens methods:
```
class PagesController < ApplicationController
  before_action :set_kitten_url, only: [:kitten, :kittens]

```
  def kitten
  end

  def kittens
  end

```

def set_kitten_url
  requested_size = params[:size]
  @kitten_url = "http://lorempixel.com/#{requested_size}/#{requested_size}/cats"
end
```
What this code does is tell Rails that if it's going to run either kitten or kittens, it needs to run set_kitten_url first. Now we don't have to explicitly call set_kitten_url inside either method. Test out this new route as well as the original kitten route and commit if everything is working!

## Redirecting and the Flash Hash
___
Sometimes instead of immediately rendering a view in response to a client's request, you'll want to redirect them to another route.

Let's say our app's contest has ended and if anyone tries to visit /contest we need to redirect them to the welcome page instead. We can do this by adding the following code to our contest method
```
redirect_to "/welcome"
```
redirect_to is a Rails method that takes one string argument representing the URL that you want to redirect (make a new GET request) to. In this case we are redirecting the user to the URL /welcome. Try navigating to /contest after making this change, and you should find yourself redirected to /welcome and be looking at the welcome view.

It would be nice to show our user a message explaining why they were just redirected. In Rails, we store these types of messages in a special hash called flash. Just like params, flash is a hash that Rails manages for you. Its contents get cleared after every request cycle. Typically what we use it for is storing one-off messages that we want to display to the user. If you look in our layout (app/views/layouts/application.html.erb), you'll see that any messages stored in flash under the keys :alert or :notice will be displayed at the top of the page. By convention Rails developers put user-facing messages about things that went wrong in the last request (invalid form data, for example) in flash[:alert] and other less negative messages to the user in flash[:notice]. Let's follow this convention and put a message to our user in flash[:notice]:

```
def contest
  flash[:notice] = "Sorry, the contest has ended"
  redirect_to "/welcome"
end
```
Because of the code in our layout, this message will appear to the user at the top of the page after they are redirected. Since flash gets emptied out after every request, if you refresh the page or navigate to a different one, the message will disappear. Try it! Make a git commit if you have it working.

### Conditional Redirects
Often you will want to redirect your user only if a certain condition is true. Perhaps we want to redirect our user away from a page only if they aren't authorized to see it. Let's set up a "secrets" page that users can only get to if they include a secret password in the URL.

We'll do this by setting up a dynamic route:
```
get '/secrets/:magic_word' => 'pages#secrets'
```
As usual, you should also create a corresponding secrets method in your controller.

Verify that the route works by navigating to that URL (just fill in anything after the second / for now). You should see the secrets view.

Our goal is to make it so that only the correct magic word will allow you to see the secrets page. You can do this by putting a redirect_to inside an if statement that compares params[:magic_word] (the wildcard from the URL) to a string that contains the magic word of your choosing and see if they match. It's up to you what other URL you want to redirect them to in the case that the magic words don't match.

Try filling your chosen magic word into the URL and verify that you still see the secrets page. Now try filling in the wrong magic word, and you should be redirected away.

It would also be nice to show the user a message about why they are being redirected:
```
flash[:alert] = "Sorry, you're not authorized to see that page!"
```
Commit once you have that working.

## Route Helpers
___
Rails provides a group of methods that help you generate the URLs for all your routes. These methods are called "route helpers". An example of a route helper in this app is the method welcome_path, which will return the string "/welcome".

How do we know what route helpers exist in our app? The output of rails routes tells us

The rails routes Task
rails routes is a very useful command when you’re learning the ins and outs of routing in Rails. It prints a summary of all the routes that exist in your app:

https://github.com/bitmakerlabs/routing-controllers-intro/blob/master/rake_routes.png?raw=true

Each row describes a different route in your app. The 2nd, 3rd, and 4th columns are fairly straightforward; they list the HTTP method of the route, the URL of the route, and the controller method that handles requests to that route, respectively. The first column ("prefix") is the most mysterious, and it’s the one that answers our current question about route helpers.

If there is a word in this prefix column that means there are two route helper methods for that specific route: one route helper that ends in \_url and another that ends in \_path. So for this app the route helpers are:

welcome_url, which returns "http://localhost:3000/welcome"

welcome_path, which returns "/welcome"

about_url, which returns "http://localhost:3000/about"

about_path, which returns "/about"

contest_url, which returns "http://localhost:3000/contest"

contest_path, which returns "/contest"

You can use these methods in place of hard coding any of these URLs throughout your controllers (such as in redirects) and views (such as in links). These are the only places in your code where you can call these methods, so trying to use them in your model code or in the rails console will not work, unfortunately.

Route helpers are helpful for two main reasons: 1. they make it so that you don’t have to try to remember all your URLs, and 2. If you use them consistently throughout your code and then find that you want to change one of the URLs your app uses, you only have to make that change in routes.rb and nowhere else. The route helpers will consult the contents of routes.rb in order to figure out the correct URL every time you call one of those methods.

What about the routes that don’t have anything in the prefix column? You may notice this is the case for all our dynamic routes, and for the root route ("/"). Rails won’t automatically generate route helpers for these routes, but it doesn’t take much extra code to make them available.

Try replacing this line in your routes.rb
```
get '/' => 'pages#welcome'
```
with this alternate way of defining your app’s root route:
```
root 'pages#welcome'
```
and then run rails routes again. See how this makes the word root appear in the prefix column for this route? Now we have two more route helper methods available to us:

root_url, which returns "http://localhost:3000/" root_path, which returns "/"

As for our dynamic routes, we can come up with a route helper prefix for them by adding an as option when we define the routes. For example, if I want to add the route helpers kitten_path and kitten_url to my app, I can modify my routes.rb to look like this:

```
get '/kitten/:size' => 'pages#kitten', as: 'kitten'
```
If you make the same change and run rails routes again you should see that this route now has kitten as the value in the prefix column. Try changing the word after as: in routes.rb and see the change get reflected in rails routes.

Use this approach to create route helpers for each of the dynamic routes in your app. Use whatever word you wish for the prefix.

The one thing to remember about using route helpers for dynamic routes such as these is the actual URL for these routes can vary. Meaning both /kitten/100 and kitten/7 are valid URLs for this route. If you want your Rails app to generate a URL for one of these dynamic routes, it can’t possibly know what number (or magic word, or whatever) to fill in unless you specify. For this reason, route helpers for dynamic routes expect you to pass them an argument when you call them (or multiple arguments if there are multiple parts of the URL that can change but that doesn’t apply to any routes in our app). For example, calling kitten_path(100) will return the string /kitten/100, and calling kitten_path(7) will return the string /kitten/7. Just calling kitten_path with no arguments will not reliably return a valid URL, because what would the number be?

Your task now is to go through your code and use the appropriate route helper in place of any hard coded URLs. Verify that the behaviour of your app stays the same and then commit!

Once you have that working, you should try messing around with different parts of routes.rb and see how the changes get reflected in the output of rails routes each time.

## Congratulations
___
You're a routing and controller wizard now.
___
# Routing and Controllers in Rails

Please follow [the instructions in Alexa.](https://alexa.bitmaker.co/assignments/2036/latest)
