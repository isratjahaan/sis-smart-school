import SchoolPublicPage from './school/[slug]/page';

export default async function RootHomePage() {
  return <SchoolPublicPage params={Promise.resolve({ slug: 'sas-smart-school' })} />;
}
