import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key, required this.onAccepted});

  static final Uri _termsUri = Uri.parse(
    'https://www.bcb.gob.bo/webdocs/files_noticias/28feb26%20CP%209%20BCB%20levanta%20inhabilitaci%C3%B3n%20Serie%20B.PDF',
  );

  final VoidCallback onAccepted;

  Future<void> _openDocument(BuildContext context) async {
    final launched = await launchUrl(
      _termsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Términos y Condiciones',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Esta aplicación ofrece únicamente una guía visual basada en los rangos de series declarados como inhabilitados por el Banco Central de Bolivia (BCB) en el comunicado CP-9/2026.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Puedes consultar el documento oficial directamente aquí: ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Comunicado oficial del BCB (PDF)',
                              style: textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF13EC5B),
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _openDocument(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La aplicación no se hace responsable si el BCB modifica, actualiza o elimina estos rangos en el futuro. Se recomienda mantener la aplicación actualizada para contar con la información más reciente.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Al pulsar "Aceptar", confirmas que has leído y entendido estos términos y que la verificación realizada aquí es referencial y no reemplaza la validación de una entidad financiera autorizada.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccepted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13EC5B),
                    foregroundColor: const Color(0xFF0B1A12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Aceptar y continuar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
