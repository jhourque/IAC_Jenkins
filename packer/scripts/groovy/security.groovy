#!groovy

import jenkins.model.JenkinsLocationConfiguration
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins

jlc = JenkinsLocationConfiguration.get()
jlc.setUrl("http://localhost:8080/")
jlc.save()

println "--> enabling CSRF protection"

def instance = Jenkins.instance
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()

println "--> Deleting createuser.groovy"

String filename = "/var/lib/jenkins/init.groovy.d/createuser.groovy"
def fileToDelete = new File(filename)
boolean deleted = fileToDelete.delete()
println deleted
