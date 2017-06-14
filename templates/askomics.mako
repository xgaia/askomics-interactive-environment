<%namespace name="ie" file="ie.mako" />
<%
# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()

# Define a volume that will be mounted into the container.
# This is a useful way to provide access to large files in the container,
# if the user knows ahead of time that they will need it.
## user_file = ie_request.volume(
##     hda.file_name, '/import/file.dat', how='ro')

user_file = ie_request.volume(
    '/home/imx/Workspace/galaxy/database/files/000', '/mounted/upload/Galaxy', how='ro')

# Get a random API key
import random
import string
askomics_api_key = ''.join([random.choice(string.ascii_letters + string.digits) for n in xrange(20)])

# Launch the IE. This builds and runs the docker command in the background.
ie_request.launch(
    volumes=[user_file],
    env_override={
        'ASKOMICS_LOAD_URL': 'http://localhost:6543',
        'ASKOMICS_ALLOWED_UPLOAD': 'false',
        'ASKOMICS_FILES_DIR': '/mounted',
        'ASKOMICS_API_KEY': askomics_api_key
    }
)

# Only once the container is launched can we template our URLs. The ie_request
# doesn't have all of the information needed until the container is running.
url = ie_request.url_template('${PROXY_URL}/login_api_url?key=' + askomics_api_key)
%>
<html>
<head>
${ ie.load_default_js() }
</head>
<body>
<script type="text/javascript">
${ ie.default_javascript_variables() }
var url = '${ url }';
${ ie.plugin_require_config() }
requirejs(['interactive_environments', 'plugin/askomics'], function(){
    load_askomics(url);
});
</script>
<div id="main" width="100%" height="100%">
</div>
</body>
</html>
