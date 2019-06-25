package bloop.data

import bloop.engine.BuildLoader
import bloop.logging.Logger
import bloop.logging.DebugFilter
import java.nio.charset.StandardCharsets
import bloop.config.ConfigEncoderDecoders
import io.circe.Printer
import io.circe.Json
import io.circe.parser
import bloop.io.AbsolutePath
import java.nio.file.Files
import io.circe.JsonObject
import bloop.DependencyResolution
import scala.util.Try
import io.circe.ObjectEncoder
import io.circe.Decoder
import io.circe.derivation._
import java.nio.file.Path
import scala.util.Failure
import scala.util.Success

case class WorkspaceSettings(semanticDBVersion: String)

object WorkspaceSettings {

  /** File to store Metals specific settings*/
  val settingsFileName = "bloop.settings.json"
  private val settingsEncoder: ObjectEncoder[WorkspaceSettings] = deriveEncoder
  private val settingsDecoder: Decoder[WorkspaceSettings] = deriveDecoder

  def fromFile(configPath: AbsolutePath, logger: Logger): Option[WorkspaceSettings] = {
    val settingsPath = configPath.resolve(settingsFileName)
    if (settingsPath.isFile) {
      val bytes = Files.readAllBytes(settingsPath.underlying)
      logger.debug(s"Loading workspace settings from $settingsFileName")(
        DebugFilter.All
      )
      val contents = new String(bytes, StandardCharsets.UTF_8)
      parser.parse(contents) match {
        case Left(failure) => throw failure
        case Right(json) => Option(fromJson(json))
      }
    } else {
      None
    }
  }

  def write(configDir: AbsolutePath, settings: WorkspaceSettings): Either[Throwable, Path] = {
    Try {
      val jsonObject = settingsEncoder(settings)
      val output = Printer.spaces4.copy(dropNullValues = true).pretty(jsonObject)
      Files.write(
        configDir.resolve(settingsFileName).underlying,
        output.getBytes(StandardCharsets.UTF_8)
      )
    } match {
      case Failure(exception) => Left(exception)
      case Success(value) => Right(value)
    }
  }

  def fromJson(json: Json): WorkspaceSettings = {
    settingsDecoder.decodeJson(json) match {
      case Right(settings) => settings
      case Left(failure) => throw failure
    }
  }


}
