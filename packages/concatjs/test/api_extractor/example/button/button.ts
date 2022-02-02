import { ButtonBase } from 'build_bazel_rules_nodejs/packages/concatjs/test/api_extractor/example/button/button_base';
import { ButtonEvent } from 'build_bazel_rules_nodejs/packages/concatjs/test/api_extractor/example/button/button_events';

export class Button extends ButtonBase {
  event?: ButtonEvent;
}
