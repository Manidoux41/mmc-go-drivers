// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MMC Go Drivers';

  @override
  String get selectLanguage => 'Elija su idioma';

  @override
  String get continueAction => 'CONTINUAR';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get dashboard => 'Tablero';

  @override
  String get navigation => 'Navegación';

  @override
  String get planning => 'Planificación';

  @override
  String get vehicle => 'Vehículo';

  @override
  String get documents => 'Documentos';

  @override
  String get contact => 'Contacto';

  @override
  String get administration => 'Administración';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get hello => 'Hola';

  @override
  String get tier => 'Suscripción';

  @override
  String get tools => 'Herramientas';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get navAndRecording => 'Navegación y grabación';

  @override
  String helloUser(Object username) {
    return 'Hola, $username';
  }

  @override
  String get mmcAccount => 'Cuenta MMC Go';

  @override
  String get manageSubscription => 'Gestionar mi suscripción';

  @override
  String get aboutMMC => 'Acerca de MMC Go';

  @override
  String get calculatingRoute =>
      'Calculando ruta optimizada para vehículos pesados...';

  @override
  String vehicleInfo(Object registration) {
    return 'Vehículo: $registration';
  }

  @override
  String get hgvOptimized => '⚠️ Ruta optimizada para vehículos pesados';

  @override
  String get startPoint => 'Punto de partida';

  @override
  String get destination => 'Destino';

  @override
  String get waypoint => 'Punto de paso';

  @override
  String get addStep => 'Añadir etapa';

  @override
  String get chooseRoute => 'Elegir ruta';

  @override
  String get startNav => 'INICIAR';

  @override
  String get calculateRoute => 'CALCULAR RUTA';

  @override
  String get saveTrip => 'Guardar viaje';

  @override
  String get tripName => 'Nombre del viaje';

  @override
  String get tripHistory => 'Historial de viajes';

  @override
  String get stats => 'Estadísticas';

  @override
  String get speed => 'VELOCIDAD';

  @override
  String get distance => 'DISTANCIA';

  @override
  String get altitude => 'ALTITUD';

  @override
  String get universalTool => 'La herramienta universal para transportistas';

  @override
  String get dbConfig => 'Configuración de BD';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get noAccount => '¿Aún no tienes cuenta?';

  @override
  String get loginAction => 'INICIAR SESIÓN';

  @override
  String get registerAction => 'REGISTRARSE';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get passwordMinimum =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get emailRequired =>
      'El correo electrónico y la contraseña son obligatorios';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get joinMMC => 'Únete a MMC Go Drivers';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get registerAndChoosePlan => 'REGISTRARSE Y ELEGIR UN PLAN';

  @override
  String get myPlanning => 'Mi planificación';

  @override
  String get exportPdf => 'Exportar a PDF';

  @override
  String get today => 'Hoy';

  @override
  String get missionPasted => 'Misión pegada con éxito';

  @override
  String get pasteMission => 'Pegar misión copiada';

  @override
  String get rseAlerts => 'Alertas RSE';

  @override
  String get noTrips => 'No hay viajes previstos para este periodo';

  @override
  String get addPersonalMission => 'Añadir misión personal';

  @override
  String get day => 'Día';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String fromTo(Object end, Object start) {
    return 'Del $start al $end';
  }

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get bus => 'Autobús';

  @override
  String get departure => 'Salida';

  @override
  String get arrival => 'Llegada';

  @override
  String get notes => 'Notas';

  @override
  String get save => 'GUARDAR';

  @override
  String get myVehicles => 'Mis vehículos';

  @override
  String get addVehicle => 'Añadir vehículo';

  @override
  String get registration => 'Matrícula';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get height => 'Altura';

  @override
  String get length => 'Longitud';

  @override
  String get width => 'Anchura';

  @override
  String get unladenWeight => 'Peso en vacío';

  @override
  String get ptac => 'MMA';

  @override
  String get fuelType => 'Tipo de combustible';

  @override
  String get mileage => 'Kilometraje';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Eléctrico';

  @override
  String get gas => 'Gas';

  @override
  String get essence => 'Gasolina';

  @override
  String get other => 'Otro';

  @override
  String get dimensions => 'Dimensiones';

  @override
  String get weight => 'Peso';

  @override
  String get myFleet => 'Mi flota de autocares';

  @override
  String get energy => 'Energía';

  @override
  String get editVehicle => 'Editar vehículo';

  @override
  String get registrationRequired => 'Matrícula *';

  @override
  String get parkNumber => 'Número de flota';

  @override
  String get initialMileage => 'Kilometraje inicial';

  @override
  String get newMileage => 'Nuevo kilometraje (km)';

  @override
  String get vehicleModified => 'Vehículo modificado';

  @override
  String get vehicleSaved => 'Vehículo guardado';

  @override
  String deleteConfirmVehicle(Object registration) {
    return '¿Realmente desea eliminar el vehículo $registration?';
  }

  @override
  String get contactCenter => 'Centro de ayuda y contactos';

  @override
  String get techSupport => 'Soporte técnico';

  @override
  String get salesContact => 'Contacto comercial';

  @override
  String get whatsappSupport => 'Soporte de WhatsApp';

  @override
  String get faqDoc => 'FAQ y documentación';

  @override
  String get sendEmail => 'Enviar un correo electrónico';

  @override
  String get call => 'Llamar';

  @override
  String get contactMessage =>
      'Nuestro equipo está a su disposición para cualquier duda técnica o comercial.';

  @override
  String get usefulContacts => 'Contactos útiles';

  @override
  String get myDocuments => 'Mis documentos';

  @override
  String get addDocument => 'Añadir un documento';

  @override
  String get documentType => 'Tipo de documento';

  @override
  String get driverLicense => 'Permiso de conducir';

  @override
  String get fimoFco => 'FIMO/FCO';

  @override
  String get tachographCard => 'Tarjeta de tacógrafo';

  @override
  String get vehicleRegistration => 'Permiso de circulación';

  @override
  String get insuranceCert => 'Certificado de seguro';

  @override
  String get takePhoto => 'Tomar una foto';

  @override
  String get chooseFile => 'Elegir un archivo';

  @override
  String get expiryDate => 'Fecha de caducidad';

  @override
  String get expired => 'CADUCADO';

  @override
  String expiresIn(Object days) {
    return 'Caduca en $days días';
  }

  @override
  String get fileAdded => 'Archivo añadido';

  @override
  String get fileDeleted => 'Documento eliminado';

  @override
  String get replace => 'Reemplazar';

  @override
  String get add => 'Añadir';

  @override
  String get validity => 'Validez';

  @override
  String get noDocumentLoaded => 'Ningún documento cargado';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String expiresOn(Object date) {
    return 'Expira el: $date';
  }

  @override
  String get noExpiryDate => 'No se ha introducido la fecha de caducidad';

  @override
  String get chooseSubscription => 'Elegir mi suscripción';

  @override
  String get currentSubscription => 'SUSCRIPCIÓN ACTUAL';

  @override
  String get stayHere => 'QUEDARSE AQUÍ';

  @override
  String get contactUs => 'CONTÁCTENOS';

  @override
  String get subscribeAction => 'SUSCRIBIRSE';

  @override
  String get finalizeSubscription => 'Finalizar suscripción';

  @override
  String get useStripe => 'Usar Stripe';

  @override
  String get dummyPayment => 'Pago con tarjeta ficticia (Modo de prueba)';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get cvc => 'CVC';

  @override
  String get confirmDummyPayment => 'CONFIRMAR PAGO FICTICIO';

  @override
  String congratsSubscription(Object tier) {
    return '¡Felicidades! Ahora eres $tier';
  }

  @override
  String get paymentFailed => 'El pago falló o fue cancelado.';

  @override
  String get fleetAdminConsole => 'Consola de Administración de Flota';

  @override
  String get drivers => 'Conductores';

  @override
  String get fleetPlanning => 'Planificación de Flota';

  @override
  String get addDriver => 'Añadir un conductor';

  @override
  String get driverCreated => 'Cuenta creada con éxito';

  @override
  String get superAdminTitle => 'Alta Administración';

  @override
  String get users => 'Usuarios';

  @override
  String get diamondRequests => 'Solicitudes Diamante';

  @override
  String get sqlGuide => 'Guía SQL de Cliente';

  @override
  String deleteConfirmUser(Object name) {
    return '¿Seguro que quieres eliminar a $name?';
  }

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get mapLayers => 'Capas del mapa';

  @override
  String get standardView => 'Vista Plano';

  @override
  String get satelliteView => 'Vista Satélite';

  @override
  String get terrainView => 'Vista Relieve';

  @override
  String get deleteTrip => 'Eliminar trayecto';

  @override
  String get importKml => 'Importer un KML';
}
