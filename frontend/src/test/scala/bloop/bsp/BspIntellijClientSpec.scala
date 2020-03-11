package bloop.bsp

import java.io.File
import java.net.URLClassLoader
import java.nio.file.Files
import java.nio.file.StandardOpenOption

import bloop.cli.BspProtocol
import bloop.io.AbsolutePath
import bloop.logging.BspClientLogger
import bloop.logging.RecordingLogger
import bloop.util.TestUtil

object LocalBspIntellijClientSpec extends BspIntellijClientSpec(BspProtocol.Local)
object TcpBspIntellijClientSpec extends BspIntellijClientSpec(BspProtocol.Tcp)

class BspIntellijClientSpec(
    override val protocol: BspProtocol
) extends BspBaseSuite {

  private val testedScalaVersion = "2.12.8"

  test("refresh project data on buildTargets request") {
    TestUtil.withinWorkspace { workspace =>
      val buildFile = workspace.resolve("build.sbt")
      // todo setup bloop plugin
      write(
        buildFile,
        s"""
           |plugins {
           |  id 'bloop'
           |}
           |apply plugin: 'java'
           |apply plugin: 'bloop'
           |
           |name := 
           |
        """.stripMargin
      )

      val source = workspace.resolve("src/main/java/A.java")
      write(source, "public class A {}")

      val logger = new RecordingLogger(ansiCodesSupported = false)
      val bspLogger = new BspClientLogger(logger)
      val configDir = workspace.resolve(".bloop")
      val state = TestUtil.loadTestProject(configDir.underlying, logger)
      val command = createBspCommand(configDir)
      openBspConnection(state, command, configDir, bspLogger, clientName = "IntelliJ")
        .withinSession { state =>
          state.workspaceTargets
        }

    }
  }

  private def getClasspath: java.lang.Iterable[File] = {
    classOf[BloopPlugin].getClassLoader
      .asInstanceOf[URLClassLoader]
      .getURLs
      .toList
      .map(url => new File(url.getFile))
      .asJava
  }

  def write(file: AbsolutePath, content: String): Unit = {
    Files.write(
      file.toFile.toPath,
      content.getBytes,
      StandardOpenOption.CREATE,
      StandardOpenOption.TRUNCATE_EXISTING
    )
  }

}
