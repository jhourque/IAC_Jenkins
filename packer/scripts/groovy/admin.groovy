#!groovy

import jenkins.model.*
import hudson.security.*
import org.apache.commons.lang.RandomStringUtils
import groovy.json.JsonSlurper

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

int randomStringLength = 8
String charset = (('a'..'z') + ('A'..'Z') + ('0'..'9')).join()
String randomString = RandomStringUtils.random(randomStringLength, charset.toCharArray())

File file = new File("/var/lib/jenkins/adminpassword.txt")
file.write randomString

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin',randomString)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()


