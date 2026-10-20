declare module 'react' {
  export function useState<T>(v: T | (() => T)): [T, (v: T | ((p: T) => T)) => void];
  export function useEffect(f: () => any, d?: any[]): void;
  export function useLayoutEffect(f: () => any, d?: any[]): void;
  export function useMemo<T>(f: () => T, d: any[]): T;
  export function useCallback<T>(f: T, d: any[]): T;
  export function useRef<T>(v: T): { current: T };
  export function useId(): string;
  export function useSyncExternalStore<T>(subscribe: (cb: () => void) => () => void, get: () => T, getServer?: () => T): T;
  export type ReactNode = any; export type FormEvent = any; export type CSSProperties = any;
  const React: any; export default React;
}
declare namespace React {
  type ReactNode = any; type FormEvent = any; type CSSProperties = any; type MouseEvent<T = any> = any; type ChangeEvent<T = any> = any;
  type ButtonHTMLAttributes<T> = { [k: string]: any }; type HTMLAttributes<T> = { [k: string]: any }; type AnchorHTMLAttributes<T> = { [k: string]: any };
  type InputHTMLAttributes<T> = { [k: string]: any }; type ComponentProps<T> = { [k: string]: any }; type ComponentPropsWithoutRef<T> = { [k: string]: any };
  type ElementType = any; type FC<P = {}> = (p: P) => any; type PropsWithChildren<P = {}> = P & { children?: any };
}
declare module 'next/navigation' { export function useRouter(): any; export function useParams(): any; export function usePathname(): string; export function redirect(u: string): never; export function notFound(): never; export function useSearchParams(): any; }
declare module 'next/link' { const Link: any; export default Link; }
declare module 'next/image' { const Image: any; export default Image; }
declare module 'next/server' { export const NextResponse: any; export type NextRequest = any; }
declare module 'next/headers' { export function cookies(): any; }
declare module '@supabase/ssr' { export function createServerClient(...a: any[]): any; export function createBrowserClient(...a: any[]): any; }
declare module '@supabase/supabase-js';
declare module 'lucide-react';
declare module 'framer-motion';
declare module '@google/generative-ai';
declare var process: any;
declare namespace JSX { interface IntrinsicElements { [k: string]: any } interface Element {} interface IntrinsicAttributes { key?: any } interface ElementChildrenAttribute { children: {} } }
