# frozen_string_literal: true

class MessageProcessor
  def initialize(
    unpacker: UnPacker.new(CounterPartyFinder.new),
    auditor: Auditor.new,
    location_finder: LocationFinder.new,
    domestic_notifier: DomesticNotifier.new,
    imported_notifier: ImportedNotifier.new
  )
    @unpacker = unpacker
    @auditor = auditor
    @location_finder = location_finder
    @domestic_notifier = domestic_notifier
    @imported_notifier = imported_notifier
  end

  def on_message(message)
    unpacked = unpacker.unpack(message)
    auditor.record_receipt_of(unpacked)

    if location_finder.is_domestic(unpacked)
      domestic_notifier.notify(unpacked.as_domestic_message)
    else
      imported_notifier.notify(unpacked.as_imported_message)
    end
  end

  private

  attr_reader :unpacker, :auditor
  attr_reader :location_finder, :domestic_notifier, :imported_notifier
end

