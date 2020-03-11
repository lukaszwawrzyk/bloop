[1mdiff --git a/build.sbt b/build.sbt[m
[1mindex c537de72..496a03d4 100644[m
[1m--- a/build.sbt[m
[1m+++ b/build.sbt[m
[36m@@ -562,7 +562,7 @@[m [mlazy val sbtBloop013 = project[m
 [m
 lazy val sbtBloop013Shaded =[m
   defineShadedSbtPlugin("sbtBloop013Shaded", Sbt013Version, sbtBloop013).settings([m
[31m-    scalaVersion := (scalaVersion in sbtBloop013).value,[m
[32m+[m[32m    scalaVersion := (scalaVersion in sbtBloop013).value[m
   )[m
 [m
 lazy val mavenBloop = project[m
[36m@@ -808,7 +808,7 @@[m [mval bloop = project[m
             sbtBloop013Shaded,[m
             sbtBloop10Shaded,[m
             mavenBloop,[m
[31m-            gradleBloop211,[m
[32m+[m[32m//            gradleBloop211,[m
             gradleBloop212,[m
             millBloop,[m
             nativeBridge03,[m
[1mdiff --git a/frontend/src/test/scala/bloop/bsp/BspBaseSuite.scala b/frontend/src/test/scala/bloop/bsp/BspBaseSuite.scala[m
[1mindex 29f8159c..dd4cdd5f 100644[m
[1m--- a/frontend/src/test/scala/bloop/bsp/BspBaseSuite.scala[m
[1m+++ b/frontend/src/test/scala/bloop/bsp/BspBaseSuite.scala[m
[36m@@ -523,6 +523,16 @@[m [mabstract class BspBaseSuite extends BaseSuite with BspClientTest {[m
       bloopExtraParams: BloopExtraBuildParams = BloopExtraBuildParams.empty,[m
       compileStartPromises: Option[mutable.HashMap[bsp.BuildTargetIdentifier, Promise[Unit]]] = None[m
   )(runTest: ManagedBspTestState => Unit): Unit = {[m
[32m+[m[32m    case class Item(name: String, amount: Int, price: Double)[m
[32m+[m[32m    java.util.Arrays[m
[32m+[m[32m      .asList(Item("", 1, 1.0))[m
[32m+[m[32m      .stream()[m
[32m+[m[32m      .reduce[Double]([m
[32m+[m[32m        0.0,[m
[32m+[m[32m        (acc: Double, item: Item) => acc + item.price * item.amount,[m
[32m+[m[32m        (_: Double) + _[m
[32m+[m[32m      )[m
[32m+[m
     val bspLogger = new BspClientLogger(logger)[m
     val configDir = TestProject.populateWorkspace(workspace, projects)[m
     val bspCommand = createBspCommand(configDir)[m
[1mdiff --git a/frontend/src/test/scala/bloop/bsp/BspIntellijClientSpec.scala b/frontend/src/test/scala/bloop/bsp/BspIntellijClientSpec.scala[m
[1mindex 3d0136e5..e0c7e08d 100644[m
[1m--- a/frontend/src/test/scala/bloop/bsp/BspIntellijClientSpec.scala[m
[1m+++ b/frontend/src/test/scala/bloop/bsp/BspIntellijClientSpec.scala[m
[36m@@ -1,33 +1,15 @@[m
[31m-package bloop.integrations.gradle[m
[32m+[m[32mpackage bloop.bsp[m
 [m
[31m-import org.gradle.testkit.runner.GradleRunner[m
[32m+[m[32mimport java.io.File[m
[32m+[m[32mimport java.net.URLClassLoader[m
[32m+[m[32mimport java.nio.file.Files[m
[32m+[m[32mimport java.nio.file.StandardOpenOption[m
 [m
[31m-import bloop.io.AbsolutePath[m
 import bloop.cli.BspProtocol[m
[31m-import bloop.util.TestUtil[m
[31m-import bloop.util.TestProject[m
[31m-import bloop.logging.RecordingLogger[m
[32m+[m[32mimport bloop.io.AbsolutePath[m
 import bloop.logging.BspClientLogger[m
[31m-import bloop.cli.ExitStatus[m
[31m-import bloop.data.WorkspaceSettings[m
[31m-import bloop.internal.build.BuildInfo[m
[31m-import bloop.bsp.BloopBspDefinitions.BloopExtraBuildParams[m
[31m-[m
[31m-import java.nio.file.{Files, Paths}[m
[31m-[m
[31m-import io.circe.JsonObject[m
[31m-import io.circe.Json[m
[31m-[m
[31m-import monix.execution.Scheduler[m
[31m-import monix.execution.ExecutionModel[m
[31m-import monix.eval.Task[m
[31m-[m
[31m-import scala.concurrent.duration.FiniteDuration[m
[31m-[m
[31m-import ch.epfl.scala.bsp.endpoints.BuildTarget.scalacOptions[m
[31m-import bloop.engine.ExecutionContext[m
[31m-import scala.util.Random[m
[31m-import bloop.bsp._[m
[32m+[m[32mimport bloop.logging.RecordingLogger[m
[32m+[m[32mimport bloop.util.TestUtil[m
 [m
 object LocalBspIntellijClientSpec extends BspIntellijClientSpec(BspProtocol.Local)[m
 object TcpBspIntellijClientSpec extends BspIntellijClientSpec(BspProtocol.Tcp)[m
[36m@@ -40,8 +22,54 @@[m [mclass BspIntellijClientSpec([m
 [m
   test("refresh project data on buildTargets request") {[m
     TestUtil.withinWorkspace { workspace =>[m
[31m-      GradleRunner.create()[m
[32m+[m[32m      val buildFile = workspace.resolve("build.sbt")[m
[32m+[m[32m      // todo setup bloop plugin[m
[32m+[m[32m      write([m
[32m+[m[32m        buildFile,[m
[32m+[m[32m        s"""[m
[32m+[m[32m           |plugins {[m
[32m+[m[32m           |  id 'bloop'[m
[32m+[m[32m           |}[m
[32m+[m[32m           |apply plugin: 'java'[m
[32m+[m[32m           |apply plugin: 'bloop'[m
[32m+[m[32m           |[m
[32m+[m[32m           |name :=[m[41m [m
[32m+[m[32m           |[m
[32m+[m[32m        """.stripMargin[m
[32m+[m[32m      )[m
[32m+[m
[32m+[m[32m      val source = workspace.resolve("src/main/java/A.java")[m
[32m+[m[32m      write(source, "public class A {}")[m
[32m+[m
[32m+[m[32m      val logger = new RecordingLogger(ansiCodesSupported = false)[m
[32m+[m[32m      val bspLogger = new BspClientLogger(logger)[m
[32m+[m[32m      val configDir = workspace.resolve(".bloop")[m
[32m+[m[32m      val state = TestUtil.loadTestProject(configDir.underlying, logger)[m
[32m+[m[32m      val command = createBspCommand(configDir)[m
[32m+[m[32m      openBspConnection(state, command, configDir, bspLogger, clientName = "IntelliJ")[m
[32m+[m[32m        .withinSession { state =>[m
[32m+[m[32m          state.workspaceTargets[m
[32m+[m[32m        }[m
[32m+[m
     }[m
   }[m
 [m
[32m+[m[32m  private def getClasspath: java.lang.Iterable[File] = {[m
[32m+[m[32m    classOf[BloopPlugin].getClassLoader[m
[32m+[m[32m      .asInstanceOf[URLClassLoader][m
[32m+[m[32m      .getURLs[m
[32m+[m[32m      .toList[m
[32m+[m[32m      .map(url => new File(url.getFile))[m
[32m+[m[32m      .asJava[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  def write(file: AbsolutePath, content: String): Unit = {[m
[32m+[m[32m    Files.write([m
[32m+[m[32m      file.toFile.toPath,[m
[32m+[m[32m      content.getBytes,[m
[32m+[m[32m      StandardOpenOption.CREATE,[m
[32m+[m[32m      StandardOpenOption.TRUNCATE_EXISTING[m
[32m+[m[32m    )[m
[32m+[m[32m  }[m
[32m+[m
 }[m
[1mdiff --git a/integrations/sbt-bloop/src/main/scala/bloop/integrations/sbt/SbtBloop.scala b/integrations/sbt-bloop/src/main/scala/bloop/integrations/sbt/SbtBloop.scala[m
[1mindex ca62853e..55ed1c35 100644[m
[1m--- a/integrations/sbt-bloop/src/main/scala/bloop/integrations/sbt/SbtBloop.scala[m
[1m+++ b/integrations/sbt-bloop/src/main/scala/bloop/integrations/sbt/SbtBloop.scala[m
[36m@@ -33,8 +33,7 @@[m [mimport xsbti.compile.CompileOrder[m
 import scala.util.{Try, Success, Failure}[m
 import java.util.concurrent.ConcurrentHashMap[m
 import java.nio.file.StandardCopyOption[m
[31m-[m
[31m-object BloopPlugin extends AutoPlugin {[m
[32m+[m[32m==dobject BloopPlugin extends AutoPlugin {[m
   import sbt.plugins.JvmPlugin[m
   override def requires = JvmPlugin[m
   override def trigger = allRequirements[m
