# Sign In With Apple

Steps to Enable Sign In With Apple


## Apple App ID
1. First, sign in to the Apple Developer Portal and click on Certificates, Identifiers and Profiles.

![image](.github/images/1.png)

2.  Next, Navigate to Identifiers. On the Identifiers page, you can see a list of registered App IDs. If you don’t have any App ID, you will have to create a new one.

- If you don’t have App IDs, please click this [link](https://documentation.wilcity.com/knowledgebase/how-to-config-apple-login/#create-app-ids)
- If you already have the App IDs. please click this [link](https://documentation.wilcity.com/knowledgebase/how-to-config-apple-login/#edit-existing)


#### Create the App IDs

1. Select App IDs 

![image](.github/images/2.png)

2. On the next screen, please write something about your app to description field and set Explicit to Bundle ID. The Bundle ID is best when it’s a reverse-dns style string.

![image](.github/images/3.png)
*For example:  you should use `com.yoursite` if your site address is `yoursite.com`.*

3. Scroll down through the list of capabilities and check the box next to Sign In with Apple.

![image](.github/images/4.png)

4. Confirm this step


#### Edit Existing App IDs

1. Click on your App IDs Name:

![image](.github/images/5.png)

2. You will see the list of the App ID Configuration here, scroll down to find Sign In With Apple, check the tick box at (1), then click edit at (2):

![image](.github/images/6.png)

3. After clicking on (2), make sure you choose Enable as a primarily App ID. Finally, click Save button to save the changes.

![image](.github/images/7.png)


## Step 2: Create a Services ID (Client ID)

> This is required to make single login experience.

The Services ID (`CLIENT_ID`) will identify the particular instance of your app, and is used as the OAuth `client_id`.

1. Go ahead and create a new identifier and choose Services IDs.

![image](.github/images/8.png)
*In the next step, you’ll define the name of the app that the user will see during the login flow, as well as define the identifier which becomes the OAuth*

2. Check the Sign In with Apple checkbox.

![image](.github/images/9.png)

3. You’ll also need to click the Configure button next to Sign In with Apple in this step. This is where you’ll define the domain your app is running on, as well as define the redirect URLs used during the OAuth flow.


![image](.github/images/10.png)

4. Make sure your associated App ID is chosen as the Primary App ID. (If this is the first App ID you’ve made that uses Sign In with Apple, then it will probably already be selected.)

5. Enter the domain name your app will eventually be running at, and enter the redirect URL for your app as well.

    Redirect format:  https://my-project.com

> ⚠️ Redirect URL must be secure. Apple **does not** allow `localhost`or IP addresses like `127.0.0.1` and will fail later in the flow. You have to use a real and secure domain here.

6. Go ahead and click Save and then Continue and Register until this step is all confirmed.

7. At this point, you now have an App ID container to hold everything, and you’ve created a Services ID which you’ll use as your OAuth 


## Step 3: Create a Private Key for Client Authentication

> Rather than using simple strings as OAuth client secrets, Apple has decided to use a public/private key pair, where the client secret is actually a signed JWT. This next step involves registering a new private key with Apple.

1. Back in the main Certificates, Identifiers & Profiles screen, choose Keys from the side navigation.

![image](.github/images/11.png)

2. Click the blue plus icon to register a new key. Give your key a name, and check the Sign In with Apple checkbox.

![image](.github/images/12.png)

3. Click the Configure button and select your primary App ID you created earlier.

![image](.github/images/13.png)

4. Apple will generate a new private key for you and let you download it only once. Make sure you SAVE this file, because you won’t be able to get it back again later! The file you download will end in `.p8`

![image](.github/images/14.png)

5. go back and view the key information to find your Key ID which you’ll need in the next step.

![image](.github/images/15.png)

#### Generate the Client Secret

1. Make sure you’ve got Ruby installed, and then install the JWT gem by running this from the command line:

    ```sh
    gem install jwt
    ```

    Now the `jwt`gem should be available for use. Fill in the missing values at the top of this file, and save it as `client_secret.rb`. You should already have the `client_id` value from the previous step.

2. You’ll also need your Apple Team ID. This is displayed in a few places, but the most convenient is in the top right corner of the screen. Use the Key ID you found in the previous step.

    Example File [client_secret.rb](./client_secret.rb)

    ```ruby
    require 'jwt'

    key_id = '' # Key ID from Apple Developer Portal
    key_file = 'AuthKey_<key_id>.p8'
    team_id = '' # Team ID from Apple Developer Portal
    client_id = '' # Services ID from Apple Developer Portal

    ecdsa_key = OpenSSL::PKey::EC.new IO.read key_file

    headers = {
    'kid' => key_id
    }

    claims = {
        'iss' => team_id,
        'iat' => Time.now.to_i,
        'exp' => Time.now.to_i + 86400*180,
        'aud' => 'https://appleid.apple.com',
        'sub' => client_id,
    }

    token = JWT.encode claims, ecdsa_key, 'ES256', headers

    puts token
    ```

    This code generates a JWT using the ES256 algorithm which includes a handful of claims. **This JWT expires in 6 months**, which is the **maximum lifetime Apple will allow**. If you’re generating a new client secret JWT every time a user authenticates, then you should use a much shorter expiration date, but this allows us to generate the secret once and use it in our sample apps easily.

3. Now you can run this from the command line and it will output a JWT.

    ```sh
    ruby client_secret.rb
    ```

    > Example Result
    
    ```text
    eyJraWQiOiJGUVVBN0RYUkJGIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiI3TUM2VVpSMlVWIiwiaWF0IjoxNTU5NjE0MjU2LCJleHAiOjE1NzUxNjYyNTYsImF1ZCI6Imh0dHBzOi8vYXBwbGVpZC5hcHBsZS5jb20iLCJzdWIiOiJsb2wuYXZvY2Fkby5jbGllbnQifQ.t6wIFrSKwuCZsJ9I1TWWBCdxmUMG3g0kNyNnxhkpG3oZAKY2UdXqL5CyRGTa21OYHa6ir1JFWkdBDjTNvt8hYC
    ```