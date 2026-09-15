import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:petvita/application/ports/platform_ports.dart';
import 'package:petvita/core/constants/app_colors.dart';
import 'package:petvita/core/theme/app_theme.dart';
import 'package:petvita/core/utils/calendar_day.dart';
import 'package:petvita/core/utils/operation_result.dart';
import 'package:petvita/core/widgets/gradient_background.dart';
import 'package:petvita/data/models/pet.dart';
import 'package:petvita/i18n/generated/app_localizations.dart';
import 'package:petvita/presentation/failures/app_failure_localizer.dart';
import 'package:petvita/presentation/formatters/bidi_text_direction.dart';
import 'package:petvita/presentation/images/pet_image_cache.dart';
import 'package:petvita/presentation/manager/upcoming_maintenance/upcoming_maintenance_cubit.dart';
import 'package:petvita/presentation/manager/vehicle_list/pet_cubit.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Pet? pet;

  const AddEditVehicleScreen({super.key, this.pet});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _birthDateController;

  Uint8List? _selectedImageBytes;
  bool _imageLoaded = true;
  bool _imageWasChanged = false;
  DateTime? _selectedBirthDate;
  bool _isSubmitting = false;

  bool get _isEditing => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final v = widget.pet;
    _nameController = TextEditingController(text: v?.name ?? '');
    _selectedBirthDate = v?.birthDate == null
        ? null
        : CalendarDay.clampToToday(v!.birthDate!);
    _birthDateController = TextEditingController(
      text: _selectedBirthDate == null
          ? ''
          : DateFormat.yMMMd().format(_selectedBirthDate!),
    );
    _breedController = TextEditingController(text: v?.breed ?? '');
    _selectedImageBytes = v?.image;
    _imageLoaded = v?.imageLoaded ?? true;
    if (v != null && !_imageLoaded && v.id != null) {
      _loadExistingImage(v.id!);
    }
  }

  Future<void> _loadExistingImage(int petId) async {
    try {
      final bytes = await context.read<PetImageCache>().load(petId);
      if (!mounted || _imageWasChanged) return;
      setState(() {
        _selectedImageBytes = bytes;
        _imageLoaded = true;
      });
    } catch (_) {
      // A failed optional preview must not erase the stored image on save.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(VehicleImageSource source) async {
    final imageBytes = await context
        .read<VehicleImagePickerPort>()
        .pickVehicleImage(source);

    if (imageBytes != null) {
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = imageBytes;
        _imageLoaded = true;
        _imageWasChanged = true;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.chooseFromGallery,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  _pickImage(VehicleImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.takePhoto,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  _pickImage(VehicleImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_selectedImageBytes != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.urgentReminderText,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.removePhoto,
                    style: TextStyle(color: AppColors.urgentReminderText),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedImageBytes = null;
                      _imageLoaded = true;
                      _imageWasChanged = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final today = CalendarDay.dateOnly(DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: CalendarDay.clampToToday(
        _selectedBirthDate ?? today,
        today: today,
      ),
      firstDate: DateTime(1950),
      lastDate: today,
      builder: (_, child) => child!,
    );
    if (!context.mounted) return;
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat.yMMMd(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.invalidEmptyEntry(
                AppLocalizations.of(context)!.petBirthDate,
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: AppColors.urgentReminderText,
          ),
        );
        return;
      }

      final vehicleData = Pet(
        id: widget.pet?.id,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim().isNotEmpty
            ? _breedController.text.trim()
            : null,
        birthDate: _selectedBirthDate,
        mileage: widget.pet?.mileage ?? 0,
        mileageLastUpdated: widget.pet?.mileageLastUpdated ?? DateTime.now(),
        boughtDate: widget.pet?.boughtDate ?? DateTime.now(),
        image: _selectedImageBytes,
        imageLoaded: _imageLoaded,
      );

      setState(() {
        _isSubmitting = true;
      });
      final cubit = context.read<PetCubit>();
      final OperationResult result = _isEditing
          ? await cubit.updateVehicle(vehicleData)
          : await cubit.addVehicle(vehicleData);
      if (!mounted) return;
      if (result is OperationFailure) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.failure.toLocalizedMessage(AppLocalizations.of(context)!),
            ),
            backgroundColor: AppColors.urgentReminderText,
          ),
        );
        return;
      }
      if (result case OperationSuccess(followUpFailure: final failure?)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.failure.toLocalizedMessage(AppLocalizations.of(context)!),
            ),
            backgroundColor: AppColors.urgentReminderText,
          ),
        );
      }

      final imageCache = context.read<PetImageCache>();
      final petId = widget.pet?.id;
      if (petId == null) {
        imageCache.clear();
      } else {
        imageCache.invalidate(petId);
      }

      await context.read<UpcomingMaintenanceCubit>().loadAllUpcomingMaintenance(
        AppLocalizations.of(context),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onPrimary;

    Widget formField(
      TextEditingController controller,
      String label,
      String? hint, {
      TextInputType keyboardType = TextInputType.text,
      bool isRequired = false,
      String? Function(String?)? validator,
      List<TextInputFormatter>? inputFormatters,
      Key? fieldKey,
      bool useNaturalTextDirection = false,
    }) {
      Widget buildTextFormField(TextDirection? textDirection) {
        return TextFormField(
          key: fieldKey,
          controller: controller,
          style: TextStyle(color: themeExtensions.textColorOnBackground),
          decoration: InputDecoration(labelText: label, hintText: hint),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textDirection: textDirection,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return AppLocalizations.of(context)!.invalidEmptyEntry(label);
            }
            return validator != null ? validator(value) : null;
          },
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: useNaturalTextDirection
            ? ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return buildTextFormField(
                    BidiTextDirection.resolve(
                      value.text,
                      fallback: Directionality.of(context),
                    ),
                  );
                },
              )
            : buildTextFormField(null),
      );
    }

    return GradientBackground(
      gradient: themeExtensions.primaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(
              context,
            )!.addEditVehicle(_isEditing ? 'edit' : 'add'),
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.inverseSurface.withValues(alpha: 0.1),
          elevation: 0,
          systemOverlayStyle: AppTheme.gradientSystemOverlayStyle,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            tooltip: AppLocalizations.of(context)!.back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    button: true,
                    label: AppLocalizations.of(context)!.uploadVehicleImage,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _showImagePickerOptions,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 150),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: bgColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: _selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 36,
                                      color:
                                          themeExtensions.textColorOnBackground,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.optionalFieldLabel(
                                        AppLocalizations.of(
                                          context,
                                        )!.uploadVehicleImage,
                                        AppLocalizations.of(
                                          context,
                                        )!.optionalEntry,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeExtensions
                                            .textColorOnBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  formField(
                    _nameController,
                    AppLocalizations.of(context)!.requiredFieldLabel(
                      AppLocalizations.of(context)!.petName,
                    ),
                    null,
                    isRequired: true,
                    useNaturalTextDirection: true,
                  ),
                  formField(
                    _breedController,
                    AppLocalizations.of(context)!.petBreed,
                    AppLocalizations.of(context)!.petBreedHint,
                    useNaturalTextDirection: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      key: const ValueKey('pet-birth-date-field'),
                      controller: _birthDateController,
                      style: TextStyle(
                        color: themeExtensions.textColorOnBackground,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .requiredFieldLabel(
                              AppLocalizations.of(context)!.petBirthDate,
                            ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: themeExtensions.textColorOnBackground,
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectBirthDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.invalidEmptyEntry(
                            AppLocalizations.of(context)!.petBirthDate,
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox.square(
                            key: const ValueKey('vehicle-submit-progress'),
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(
                              context,
                            )!.addEditButtonText(_isEditing ? 'edit' : 'add'),
                            style: TextStyle(
                              color: isDark
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
