import jenkins.model.Jenkins
import hudson.model.*
import hudson.slaves.*
import hudson.security.*
import hudson.security.csrf.DefaultCrumbIssuer
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.*
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermissions

def j = Jenkins.get()
def ready = new File('/var/jenkins_home/c01-configured.json')
ready.delete()
j.setNumExecutors(0)
j.setSlaveAgentPort(-1)
if (!(j.securityRealm instanceof HudsonPrivateSecurityRealm)) {
    def realm = new HudsonPrivateSecurityRealm(false)
    realm.createAccount('bruno', new File('/run/secrets/admin_password').text.trim())
    j.setSecurityRealm(realm)
}
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
j.setAuthorizationStrategy(strategy)
j.setCrumbIssuer(new DefaultCrumbIssuer(true))
new File('/usr/share/jenkins/ref/plugins.txt').eachLine { line ->
    def parts = line.trim().split(':', 2)
    if (parts.length == 2) {
        def plugin = j.pluginManager.getPlugin(parts[0])
        if (plugin == null || plugin.version != parts[1] || !plugin.active) {
            throw new IllegalStateException('Plugin ausente/inactivo o version distinta del lock: ' + parts[0])
        }
    }
}
if (j.getNode('l4-agent') == null) {
    def node = new DumbSlave('l4-agent', '/var/jenkins_home', new JNLPLauncher())
    node.setNumExecutors(1)
    node.setLabelString('l4-dedicated')
    node.setMode(Node.Mode.NORMAL)
    node.setRetentionStrategy(RetentionStrategy.INSTANCE)
    j.addNode(node)
}
def secret = new File('/run/l4-agent/secret')
secret.text = j.getComputer('l4-agent').getJnlpMac()
Files.setPosixFilePermissions(secret.toPath(), PosixFilePermissions.fromString('rw-------'))
if (j.getItem('L4-C01-preflight') == null) {
    def job = j.createProject(WorkflowJob, 'L4-C01-preflight')
    job.setDefinition(new CpsFlowDefinition(new File('/opt/l4/Jenkinsfile.preflight').text, true))
    job.setDescription('Prueba C01: herramientas, Git, Docker propio y persistencia. Ejecutar manualmente; no publica ni despliega.')
    job.save()
}
if (j.getItem('L4-integral') == null) {
    def job = j.createProject(WorkflowJob, 'L4-integral')
    def url = 'https://github.com/FacundoCoria/EntregableDevops2.git'
    def ref = 'trabajo-integrador-4'
    def scm = new GitSCM([new UserRemoteConfig(url, null, null, null)], [new BranchSpec(ref)], false, [], null, null, [])
    job.setDefinition(new CpsScmFlowDefinition(scm, 'Jenkinsfile'))
    job.addProperty(new ParametersDefinitionProperty(
        new StringParameterDefinition('SOURCE_URL', url, 'Fuente publicada'),
        new StringParameterDefinition('SOURCE_REF', ref, 'Commit de entrega fijado para este entorno dedicado'),
        new StringParameterDefinition('IMAGE_REPOSITORY', 'brunovitola/pedidos-api-l4', 'Repositorio Docker Hub')))
    job.setDescription('Preparado para C07; publica imagen y despliega. Mantener deshabilitado hasta autorizar ese alcance y aportar credenciales.')
    job.setDisabled(true)
    job.save()
}
j.save()
ready.text = groovy.json.JsonOutput.toJson([
    core: Jenkins.VERSION,
    controllerExecutors: j.numExecutors,
    agentExecutors: j.getNode('l4-agent').numExecutors,
    agent: 'l4-agent',
    integralDisabled: j.getItem('L4-integral').disabled,
    plugins: j.pluginManager.plugins.collectEntries { [(it.shortName): it.version] }
])
println('L4_C01_CONFIGURED: controller executors=0; agent executors=1; integral disabled')
