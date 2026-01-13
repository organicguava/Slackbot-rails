class ActivitySummarizer
  def initialize(events)
    @events = events
  end

  def summary
    {
      push: count_by_action('pushed to'),
      merge: count_by_action('merged'),
      comment: count_by_action('commented on'),
      deleted: count_by_action('deleted')
      
    }
  end

  private

  def count_by_action(action)
    @events.count { |e| e['action_name'] == action }
  end
end