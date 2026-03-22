enum AppType {
  trash,
  slaughter;

  AppType fromCompanyCode(String companyCode) {
    switch (companyCode) {
      case 'DVTH_CamLy':
        return AppType.slaughter;
      default:
        return AppType.trash;
    }
  }
}
