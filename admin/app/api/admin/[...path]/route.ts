import { NextRequest, NextResponse } from 'next/server'

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000'

export async function POST(request: NextRequest, context: { params: Promise<{ path: string[] }> }) {
  const params = await context.params
  const path = params.path.join('/')
  const body = await request.json()
  const token = request.headers.get('authorization')

  const res = await fetch(`${BACKEND_URL}/api/admin/${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': token } : {}),
    },
    body: JSON.stringify(body),
  })

  const data = await res.json()
  return NextResponse.json(data, { status: res.status })
}

export async function GET(request: NextRequest, context: { params: Promise<{ path: string[] }> }) {
  const params = await context.params
  const path = params.path.join('/')
  const token = request.headers.get('authorization')

  const res = await fetch(`${BACKEND_URL}/api/admin/${path}`, {
    method: 'GET',
    headers: {
      ...(token ? { 'Authorization': token } : {}),
    },
  })

  const data = await res.json()
  return NextResponse.json(data, { status: res.status })
}
