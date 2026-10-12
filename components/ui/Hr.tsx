/**
 * Хорватський текст: `lang="hr"`, щоб програма читання з екрана вимовляла його
 * хорватською (§98, docs/DESIGN_SYSTEM.md §8). Обгортай ним слова, приклади,
 * репліки й відповіді AI хорватською.
 */
type HrProps = React.HTMLAttributes<HTMLElement> & {
  as?: 'span' | 'p' | 'div' | 'h1' | 'h2' | 'h3';
};

export default function Hr({ as: Tag = 'span', ...rest }: HrProps) {
  return <Tag lang="hr" {...rest} />;
}
