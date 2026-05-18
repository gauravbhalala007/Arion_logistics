import 'package:flutter/widgets.dart';

/// Local language helper for the Inventory + Cart modules.
///
/// Default language is English. German is fully translated; every other
/// locale supported by the app (sq/hu/ro/hr/ar/tr/ru) falls back to EN
/// per the user's request: "ganze Seite auf Englisch und dann je nach
/// Sprache anpassen".
class InvL10n {
  InvL10n._(this._lang);

  final String _lang;

  factory InvL10n.of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode
            .toLowerCase() ??
        'en';
    return InvL10n._(code);
  }

  String _pick(String en, String de) {
    return _lang == 'de' ? de : en;
  }

  // ─── Module names / navigation ────────────────────────────────────
  String get inventory => _pick('Inventory', 'Inventar');
  String get cart => _pick('Cart', 'Warenkorb');
  String get orders => _pick('Orders', 'Bestellungen');
  String get goodsReceipt => _pick('Goods Receipt', 'Wareneingang');

  // ─── Inventory page ───────────────────────────────────────────────
  String get inventorySubtitle => _pick(
        'Manage stock · Catalog · Sizes',
        'Bestand verwalten · Katalog · Größen',
      );
  String get searchPlaceholder => _pick(
        'Search by item, SKU, supplier…',
        'Suche nach Artikel, SKU, Lieferant…',
      );
  String get newItem => _pick('New item', 'Neuer Artikel');
  String get tabAll => _pick('All', 'Alles');
  String get tabClothing => _pick('Clothing', 'Kleidung');
  String get tabWorkshop => _pick('Workshop', 'Werkstatt');

  String get emptyTitle => _pick('No items yet', 'Noch keine Artikel');
  String get emptyBody => _pick(
        'Add items to track stock, send them to the cart and '
            'inspect incoming goods.',
        'Lege Artikel an, um Bestände zu pflegen, in den Warenkorb '
            'zu legen und eingehende Lieferungen zu prüfen.',
      );
  String get emptyCta =>
      _pick('Create first item', 'Ersten Artikel anlegen');

  String get importStandard => _pick(
        'Import standard catalog',
        'Standard-Katalog importieren',
      );
  String get importingStandard => _pick(
        'Importing…',
        'Wird importiert…',
      );
  String importedItems(int n) => _pick(
        '$n item(s) imported.',
        '$n Artikel importiert.',
      );
  String get importNoneNew => _pick(
        'All standard items are already in the catalog.',
        'Alle Standard-Artikel sind schon im Katalog.',
      );

  String get empty => _pick('Empty', 'Leer');
  String addedToCart(String name) => _pick(
        '"$name" added to cart',
        '"$name" in den Warenkorb gelegt',
      );

  // ─── Item editor ──────────────────────────────────────────────────
  String get itemEditorTitleNew => _pick('New item', 'Neuer Artikel');
  String get itemEditorTitleEdit =>
      _pick('Edit item', 'Artikel bearbeiten');
  String get photoLabel => _pick('Photo (optional)', 'Foto (optional)');
  String get photoHint => _pick(
        'Shown as preview in the list.',
        'Wird als Vorschau in der Liste angezeigt.',
      );
  String get upload => _pick('Upload', 'Hochladen');
  String get remove => _pick('Remove', 'Entfernen');
  String get category => _pick('Category', 'Kategorie');
  String get catClothing => _pick('Clothing', 'Kleidung');
  String get catWorkshop => _pick('Workshop', 'Werkstatt');
  String get catOther => _pick('Other', 'Sonstiges');
  String get nameRequired => _pick('Name *', 'Name *');
  String get nameHint =>
      _pick('e.g. Safety vest', 'z.B. Sicherheitsweste');
  String get skuLabel => _pick('SKU / Item no.', 'SKU / Art.-Nr.');
  String get unitLabel => _pick('Unit', 'Einheit');
  String get unitHint => _pick('pcs, pair, …', 'Stück, Paar, …');
  String get unitDefault => _pick('pcs', 'Stück');
  String get stockLabel => _pick('Stock', 'Bestand');
  String get lowThresholdLabel =>
      _pick('Low-stock alert', 'Warnschwelle');
  String get supplierLabel => _pick('Supplier', 'Lieferant');
  String get optional => _pick('optional', 'optional');
  String get sizesLabel =>
      _pick('Sizes / variants (optional)', 'Größen / Varianten (optional)');
  String get sizesHint => _pick('S, M, L, 42, …', 'S, M, L, 42, …');
  String get add => _pick('Add', 'Hinzufügen');
  String get notes => _pick('Notes', 'Notizen');
  String get save => _pick('Save', 'Speichern');
  String get create => _pick('Create', 'Anlegen');
  String get cancel => _pick('Cancel', 'Abbrechen');
  String get delete => _pick('Delete', 'Löschen');
  String get nameRequiredError =>
      _pick('Name is required.', 'Name ist Pflicht.');
  String get saveError => _pick(
        "Couldn't save — please try again.",
        'Konnte nicht gespeichert werden — bitte erneut versuchen.',
      );
  String get deleteError => _pick(
        "Couldn't delete — please try again.",
        'Konnte nicht gelöscht werden — bitte erneut versuchen.',
      );
  String get deleteTitle =>
      _pick('Delete item', 'Artikel löschen');
  String deleteBody(String name) => _pick(
        '"$name" will be permanently deleted.',
        '"$name" wird unwiderruflich gelöscht.',
      );
  String get imageError =>
      _pick("Couldn't load image", 'Bild konnte nicht geladen werden');

  // ─── Cart ─────────────────────────────────────────────────────────
  String get cartTitle => _pick('Cart', 'Warenkorb');
  String get cartEmpty => _pick(
        'Your cart is empty.\nAdd items from the inventory.',
        'Warenkorb ist leer.\nLege Artikel aus dem Lager hinzu.',
      );
  String cartSummary(int items, int qty) =>
      _pick('$items line(s) · $qty pcs', '$items Position(en) · $qty Stk');
  String get cartClear => _pick('Clear', 'Leeren');
  String get cartClearTitle =>
      _pick('Clear cart', 'Warenkorb leeren');
  String get cartClearBody => _pick(
        'All items in the cart will be removed.',
        'Alle Artikel im Warenkorb werden entfernt.',
      );
  String get browseInventory =>
      _pick('Browse inventory', 'Zum Lager');
  String get supplierOptional =>
      _pick('Supplier (optional)', 'Lieferant (optional)');
  String get orderRefOptional => _pick(
        'PO / delivery note no. (optional)',
        'Bestell-/Lieferschein-Nr. (optional)',
      );
  String get notesForReceiving => _pick(
        'Note for the goods receipt (optional)',
        'Notiz für die Eingangskontrolle (optional)',
      );
  String get submitOrder => _pick(
        'Submit order',
        'Bestellung abschicken',
      );
  String get submittingOrder =>
      _pick('Sending…', 'Wird gesendet…');
  String get orderCreated => _pick(
        'Order created. Goods receipt pending.',
        'Bestellung erstellt. Eingangskontrolle steht aus.',
      );

  // ─── Orders / Goods receipts ──────────────────────────────────────
  String get ordersTitle => _pick('Orders', 'Bestellungen');
  String get noOrders => _pick(
        'No orders yet.\n\nSubmitting a cart automatically '
            'creates a pending order with a goods receipt step.',
        'Noch keine Bestellungen.\n\nBeim Absenden eines Warenkorbs '
            'wird automatisch eine ausstehende Bestellung mit '
            'Eingangskontrolle erzeugt.',
      );
  String get orderWithoutSupplier => _pick(
        'Order without supplier',
        'Lieferung ohne Lieferant',
      );
  String orderMeta(String? ref, int lines, int expected) {
    final parts = <String>[
      if (ref != null && ref.isNotEmpty)
        _pick('Ref. $ref', 'Ref. $ref'),
      _pick('$lines line(s)', '$lines Position(en)'),
      _pick('expected $expected', 'erwartet $expected'),
    ];
    return parts.join(' · ');
  }

  String get statusPending => _pick('Pending', 'Erwartet');
  String get statusInReview => _pick('In review', 'In Prüfung');
  String get statusAccepted => _pick('Accepted', 'Akzeptiert');
  String get statusRejected => _pick('Rejected', 'Beanstandet');

  String get receiveGoods => _pick('Goods receipt', 'Wareneingang');
  String get reject => _pick('Reject', 'Beanstanden');
  String get acceptAndAddStock => _pick(
        'Accept & add to stock',
        'Annehmen & Bestand erhöhen',
      );
  String get booking => _pick('Booking…', 'Wird verbucht…');
  String get checkNote => _pick('Inspection note (optional)', 'Prüfnotiz (optional)');
  String get alreadyAccepted => _pick(
        'This delivery has already been accepted.',
        'Diese Lieferung wurde bereits angenommen.',
      );
  String get alreadyRejected => _pick(
        'This delivery has already been rejected.',
        'Diese Lieferung wurde bereits beanstandet.',
      );
  String expectedQty(int qty, String unit) =>
      _pick('expected $qty $unit', 'erwartet $qty $unit');
  String sizeLabel(String s) => _pick('Size $s', 'Gr. $s');

  // ─── Misc ─────────────────────────────────────────────────────────
  String get back => _pick('Back', 'Zurück');
  String get genericError => _pick(
        'Something went wrong — please try again.',
        'Etwas ist schiefgelaufen — bitte erneut versuchen.',
      );
}
