enum ComponentLifeCycleEvent {
  mount('mount'),
  unmount('unmount');

  final String description;

  const ComponentLifeCycleEvent(this.description);
}
