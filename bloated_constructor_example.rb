# frozen_string_literal: true

class MessageProcessor
  def initialize(
    unpacker: UnPacker.new(CounterPartyFinder.new),
    auditor: Auditor.new,
    dispatcher: MessageDispatcher.new
  )
    @unpacker = unpacker
    @auditor = auditor
    @dispatcher = dispatcher
  end

  def on_message(message)
    unpacked = unpacker.unpack(message)
    auditor.record_receipt_of(unpacked)

    dispatcher.dispatch(unpacked)
  end

  private

  attr_reader :unpacker, :auditor
  attr_reader :dispatcher
end

class MessageDispatcher
  def initialize(
    location_finder: LocationFinder.new,
    domestic_notifier: DomesticNotifier.new,
    imported_notifier: ImportedNotifier.new
  )
    @location_finder = location_finder
    @domestic_notifier = domestic_notifier
    @imported_notifier = imported_notifier
  end

  def dispatch(unpacked_message)
    if location_finder.is_domestic(unpacked_message)
      domestic_notifier.notify(unpacked_message.as_domestic_message)
    else
      imported_notifier.notify(unpacked_message.as_imported_message)
    end
  end
end
