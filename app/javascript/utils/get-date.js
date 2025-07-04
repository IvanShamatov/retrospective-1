import {enGB} from 'date-fns/locale';
import {formatRelative, subDays} from 'date-fns';

const formatRelativeLocale = {
  lastWeek: "'Last' eeee, 'at' HH:mm",
  yesterday: "'Yesterday', 'at' HH:mm",
  today: "'Today', 'at' HH:mm",
  tomorrow: "'Tomorrow', 'at' HH:mm",
  nextWeek: "'Next', 'at' eeee",
  other: "dd.MM.yyyy, 'at' HH:mm"
};

const locale = {
  ...enGB,
  formatRelative: (token) => formatRelativeLocale[token]
};

export const getDate = (createdAt) => {
  return formatRelative(subDays(new Date(createdAt), 0), new Date(), {locale});
};
